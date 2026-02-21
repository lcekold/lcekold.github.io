import network
import os
import time
import _thread
import gc
import ujson
import utime
import ulab.numpy as np
import nncase_runtime as nn
import aicube
import image
import multimedia as mm
from time import sleep
from media.vencoder import *
from media.sensor import *
from media.media import *
from media.display import *
from ybUtils.YbUart import YbUart
import machine
import uctypes

# ==================== 全局配置 ====================
WIFI_ID = "你的WiFi名称"
WIFI_PW = "你的WiFi密码"
SEND_INTERVAL_MS = 2000  # 串口发送间隔
ROOT_PATH = "/sdcard/mp_deployment_source/"
CONFIG_PATH = ROOT_PATH + "deploy_config.json"

# 初始化串口
uart = YbUart(baudrate=115200)

def ALIGN_UP(addr, size):
    return ((addr + size - 1) & (~(size - 1)))

def Connect_WIFI(ID, PASSWORD):
    sta = network.WLAN(0)
    if not sta.isconnected():
        print("正在连接 WiFi...")
        sta.connect(ID, PASSWORD)
    while sta.ifconfig()[0] == '0.0.0.0':
        time.sleep(1)
    print("WiFi 已连接，IP:", sta.ifconfig()[0])
    return True

# ==================== 火灾检测 AI 类 ====================
class FireDetectionApp:
    def __init__(self, config_path):
        # 读取 JSON 配置
        with open(config_path, 'r') as f:
            self.conf = ujson.load(f)
        
        self.kmodel_path = ROOT_PATH + self.conf["kmodel_path"]
        self.labels = self.conf["categories"]
        self.img_size = self.conf["img_size"] # 模型要求的输入尺寸 [宽, 高]
        self.threshold = self.conf["confidence_threshold"]
        self.nms_threshold = self.conf["nms_threshold"]
        self.model_type = self.conf["model_type"]
        self.num_classes = self.conf["num_classes"]
        self.strides = [8, 16, 32]
        
        # 获取 Anchor 数据
        if self.model_type == "AnchorBaseDet":
            anchors_raw = self.conf["anchors"]
            self.anchors = anchors_raw[0] + anchors_raw[1] + anchors_raw[2]
        else:
            self.anchors = []

        # 初始化 KPU 并加载模型
        self.kpu = nn.kpu()
        self.kpu.load_kmodel(self.kmodel_path)
        
        # 初始化 AI2D 预处理
        self.ai2d = nn.ai2d()
        self.ai2d.set_dtype(nn.ai2d_format.NCHW_FMT, nn.ai2d_format.NCHW_FMT, np.uint8, np.uint8)
        self.ai2d_builder = None

    def config_preprocess(self, src_size):
        """根据输入图像尺寸配置 AI2D 缩放和填充"""
        w, h = src_size
        target_w, target_h = self.img_size
        ratio = min(target_w / w, target_h / h)
        new_w, new_h = int(ratio * w), int(ratio * h)
        dw, dh = (target_w - new_w) / 2, (target_h - new_h) / 2
        
        top, bottom = int(round(dh - 0.1)), int(round(dh + 0.1))
        left, right = int(round(dw - 0.1)), int(round(dw + 0.1))
        
        self.ai2d.set_pad_param(True, [0,0,0,0, top, bottom, left, right], 0, [114, 114, 114])
        self.ai2d.set_resize_param(True, nn.interp_method.tf_bilinear, nn.interp_mode.half_pixel)
        self.ai2d_builder = self.ai2d.build([1, 3, h, w], [1, 3, target_h, target_w])

    def run(self, np_img):
        """执行模型推理"""
        input_tensor = nn.from_numpy(np_img)
        # 准备输出 Buffer
        data = np.ones((1, 3, self.img_size[1], self.img_size[0]), dtype=np.uint8)
        output_tensor = nn.from_numpy(data)
        
        self.ai2d_builder.run(input_tensor, output_tensor)
        self.kpu.set_input_tensor(0, output_tensor)
        self.kpu.run()
        
        # 获取模型输出结果
        results = []
        for i in range(self.kpu.outputs_size()):
            out = self.kpu.get_output_tensor(i)
            res = out.to_numpy()
            results.append(res.reshape(-1))
        return results

    def postprocess(self, results, frame_size):
        """调用 aicube 进行后处理"""
        if self.model_type == "AnchorBaseDet":
            return aicube.anchorbasedet_post_process(results[0], results[1], results[2], self.img_size, frame_size, self.strides, self.num_classes, self.threshold, self.nms_threshold, self.anchors, "GIOU")
        elif self.model_type == "GFLDet":
            return aicube.gfldet_post_process(results[0], results[1], results[2], self.img_size, frame_size, self.strides, self.num_classes, self.threshold, self.nms_threshold, "GIOU")
        else:
            return aicube.anchorfreedet_post_process(results[0], results[1], results[2], self.img_size, frame_size, self.strides, self.num_classes, self.threshold, self.nms_threshold, "GIOU")

# ==================== RTSP & 主业务管理 ====================
class FireRtspSystem:
    def __init__(self):
        self.rtspserver = mm.rtsp_server()
        self.venc_chn = VENC_CHN_ID_0
        self.encoder = Encoder()
        self.session_name = "fire_alarm"
        self.is_running = False
        self.last_send_time = 0

    def start(self):
        # 1. 媒体硬件初始化 (LCD 640x480, AI使用1280x720)
        self.sensor = Sensor()
        self.sensor.reset()
        
        # 通道 0 用于 LCD 显示和推流 (YUV420)
        self.sensor.set_framesize(width=640, height=480)
        self.sensor.set_pixformat(PIXEL_FORMAT_YUV_SEMIPLANAR_420)
        
        # 通道 2 用于 AI 处理 (RGB888 Planar)
        self.sensor.set_framesize(width=1280, height=720, chn=CAM_CHN_ID_2)
        self.sensor.set_pixformat(PIXEL_FORMAT_RGB_888_PLANAR, chn=CAM_CHN_ID_2)

        # 绑定 LCD 显示
        sensor_bind = self.sensor.bind_info(chn=CAM_CHN_ID_0)
        Display.bind_layer(**sensor_bind, layer=Display.LAYER_VIDEO1)
        Display.init(Display.ST7701, to_ide=True)

        # 2. 编码器与媒体管理器初始化
        MediaManager.init()
        self.encoder.SetOutBufs(self.venc_chn, 8, 640, 480)
        chnAttr = ChnAttrStr(self.encoder.PAYLOAD_TYPE_H264, self.encoder.H264_PROFILE_MAIN, 640, 480, bit_rate=1500, dst_frame_rate=20, src_frame_rate=20)
        self.encoder.Create(self.venc_chn, chnAttr)
        
        # 3. RTSP 服务启动
        self.rtspserver.rtspserver_init(8554)
        self.rtspserver.rtspserver_createsession(self.session_name, mm.multi_media_type.media_h264, False)
        self.rtspserver.rtspserver_start()

        # 4. 启动主任务线程
        self.is_running = True
        self.encoder.Start(self.venc_chn)
        self.sensor.run()
        _thread.start_new_thread(self._main_worker, ())

    def _main_worker(self):
        try:
            # 初始化 AI
            fire_ai = FireDetectionApp(CONFIG_PATH)
            fire_ai.config_preprocess([1280, 720])
            
            # 准备 OSD 图层
            osd_img = image.Image(640, 480, image.ARGB8888)
            frame_info = k_video_frame_info()
            streamData = StreamData()

            while self.is_running:
                # --- AI 推理阶段 ---
                img_ai = self.sensor.snapshot(chn=CAM_CHN_ID_2)
                raw_results = fire_ai.run(img_ai.to_numpy_ref())
                # 这里的推理是在 1280x720 尺寸上进行的
                dets = fire_ai.postprocess(raw_results, [1280, 720])
                
                # --- 结果展示与报警阶段 ---
                img_show = self.sensor.snapshot(chn=CAM_CHN_ID_0)
                osd_img.clear()
                
                if dets:
                    # 检查串口发送频率
                    curr_ticks = time.ticks_ms()
                    if time.ticks_diff(curr_ticks, self.last_send_time) > SEND_INTERVAL_MS:
                        uart.send("fire\n")
                        print("[ALERT] Fire detected! UART Sent.")
                        self.last_send_time = curr_ticks

                    # 绘制检测框
                    for det in dets:
                        # 坐标转换：从 AI 图像尺寸(1280x720)转为显示/推流尺寸(640x480)
                        x1, y1, x2, y2 = det[2], det[3], det[4], det[5]
                        nx1 = int(x1 * 640 / 1280)
                        ny1 = int(y1 * 480 / 720)
                        nw = int((x2 - x1) * 640 / 1280)
                        nh = int((y2 - y1) * 480 / 720)
                        # 绘制红色矩形框 (颜色格式：ARGB)
                        osd_img.draw_rectangle(nx1, ny1, nw, nh, color=(255, 255, 0, 0), thickness=2)
                
                # 在 LCD 屏幕上更新 OSD 层
                Display.show_image(osd_img, 0, 0, Display.LAYER_OSD3)

                # --- RTSP 推流阶段 ---
                frame_info.v_frame.width, frame_info.v_frame.height = 640, 480
                frame_info.v_frame.pixel_format = Sensor.YUV420SP
                frame_info.pool_id = img_show.poolid()
                frame_info.v_frame.phys_addr[0] = img_show.phyaddr()
                frame_info.v_frame.phys_addr[1] = frame_info.v_frame.phys_addr[0] + 640*480
                
                self.encoder.SendFrame(self.venc_chn, frame_info)
                self.encoder.GetStream(self.venc_chn, streamData)
                
                # 发送编码后的数据到 RTSP
                for i in range(streamData.pack_cnt):
                    p_data = bytes(uctypes.bytearray_at(streamData.data[i], streamData.data_size[i]))
                    self.rtspserver.rtspserver_sendvideodata(self.session_name, p_data, streamData.data_size[i], 1000)
                
                self.encoder.ReleaseStream(self.venc_chn, streamData)
                gc.collect()

        except Exception as e:
            print(f"工作线程异常: {e}")
            self.stop()

    def stop(self):
        self.is_running = False
        self.sensor.stop()
        self.encoder.Stop(self.venc_chn)
        self.rtspserver.rtspserver_stop()
        MediaManager.deinit()
        print("推流服务已停止。")

# ==================== 入口函数 ====================
if __name__ == "__main__":
    if Connect_WIFI(WIFI_ID, WIFI_PW):
        sys_manager = FireRtspSystem()
        sys_manager.start()
        
        ip = network.WLAN(0).ifconfig()[0]
        print(f"\n系统启动成功！")
        print(f"RTSP 地址: rtsp://{ip}:8554/fire_alarm")
        print("您可以打开 VLC 查看推流画面，串口正在监控火情...")
        
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            sys_manager.stop()