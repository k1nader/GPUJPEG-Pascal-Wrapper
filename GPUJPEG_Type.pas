unit GPUJPEG_Type;

interface

// 常量定义
const
  GPUJPEG_MAX_COMPONENT_COUNT = 4; // 最大颜色分量数

  // 标志位定义
const
  GPUJPEG_VERBOSE = 1; // 显示详细信息
  GPUJPEG_OPENGL_INTEROPERABILITY = 2; // 支持OpenGL互操作性

  // 流中最大段信息头数量
const
  GPUJPEG_MAX_SEGMENT_INFO_HEADER_COUNT = 100;

  // 错误代码
const
  GPUJPEG_NOERR = 0; // 无错误
  GPUJPEG_ERROR = -1; // 通用错误
  GPUJPEG_ERR_WRONG_SUBSAMPLING = -2; // 子采样模式错误
  GPUJPEG_ERR_RESTART_CHANGE = -3; // 重置间隔更改错误

  // JPEG编解码器支持的颜色空间
type
  TGPUJPEGColorSpace = (GPUJPEG_NONE = 0, GPUJPEG_RGB = 1,
    GPUJPEG_YCBCR_BT601 = 2, // 有限范围YCbCr BT.601
    GPUJPEG_YCBCR_BT601_256LVLS = 3, // 全范围YCbCr BT.601
    GPUJPEG_YCBCR_JPEG = GPUJPEG_YCBCR_BT601_256LVLS, GPUJPEG_YCBCR_BT709 = 4,
    // 有限范围YCbCr BT.709
    GPUJPEG_YCBCR = GPUJPEG_YCBCR_BT709, GPUJPEG_YUV = 5
    // @deprecated 即将移除（是否需要？），通过定义ENABLE_YUV启用预处理和后处理
    );

  // 输入/输出图像数据的像素格式
type
  TGPUJPEGPixelFormat = (GPUJPEG_PIXFMT_NONE = -1,

    /// 8bit无符号样本，1个分量
    GPUJPEG_U8 = 0,

    /// 8bit无符号样本，3个分量，4:4:4采样，样本顺序：comp#0 comp#1 comp#2，交错
    GPUJPEG_444_U8_P012 = 1,

    /// 8bit无符号样本，3个分量，4:4:4，平面格式
    GPUJPEG_444_U8_P0P1P2 = 2,

    /// 8bit无符号样本，3个分量，4:2:2，样本顺序：comp#1 comp#0 comp#2 comp#0，交错
    GPUJPEG_422_U8_P1020 = 3,

    /// 8bit无符号样本，平面格式，3个分量，4:2:2，平面格式
    GPUJPEG_422_U8_P0P1P2 = 4,

    /// 8bit无符号样本，平面格式，3个分量，4:2:0，平面格式
    GPUJPEG_420_U8_P0P1P2 = 5,

    /// 8bit无符号样本，3个分量，每个像素用零字节填充至32位，4:4:4采样，交错
    GPUJPEG_444_U8_P012Z = 6,

    /// 8bit无符号样本，3或4个分量，每个像素用可选alpha（如果有4个分量）或填充为0xFF填充至32位，4:4:4(:4)采样，交错
    GPUJPEG_444_U8_P012A = 7,

    GPUJPEG_PIXFMT_NO_ALPHA = GPUJPEG_PIXFMT_NONE - 1,
    // 表示任何不含alpha通道的像素格式占位符，放在枚举之外以避免-Wswitch警告
    GPUJPEG_PIXFMT_PLANAR_STD = GPUJPEG_PIXFMT_NONE - 2
    // 表示标准平面像素格式占位符，可能是444、422或420
    );

  // JPEG格式中颜色分量的子采样因子结构体
type
  PGPUJPEGComponentSamplingFactor = ^TGPUJPEGComponentSamplingFactor;

  TGPUJPEGComponentSamplingFactor = record
    horizontal: UInt8;
    vertical: UInt8;
  end;

  // JPEG组件类型
type
  TGPUJPEGComponentType = (GPUJPEG_COMPONENT_LUMINANCE = 0,
    GPUJPEG_COMPONENT_CHROMINANCE = 1, GPUJPEG_COMPONENT_TYPE_COUNT = 2);

  // JPEG霍夫曼编码类型
type
  TGPUJPEGHuffmanType = (GPUJPEG_HUFFMAN_DC = 0, GPUJPEG_HUFFMAN_AC = 1,
    GPUJPEG_HUFFMAN_TYPE_COUNT = 2);

implementation

end.
