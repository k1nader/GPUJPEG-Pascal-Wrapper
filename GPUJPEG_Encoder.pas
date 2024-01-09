unit GPUJPEG_Encoder;

interface

uses
  GPUJPEG_Type, GPUJPEG_Common;

type

  TGPUJPEGEncoder = Pointer;

  // 编码器输入类型枚举
  TGPUJPEGEncoderInputType = (GPUJPEG_ENCODER_INPUT_IMAGE, // 使用自定义输入缓冲区
    GPUJPEG_ENCODER_INPUT_OPENGL_TEXTURE, // 使用OpenGL纹理PBO资源作为输入缓冲区
    GPUJPEG_ENCODER_INPUT_GPU_IMAGE // 使用自定义GPU输入缓冲区
    );

  // 编码器输入结构体
  PGPUJPEGEncoderInput = ^TGPUJPEGEncoderInput;

  TGPUJPEGEncoderInput = record
    // 输入类型
    Type_: TGPUJPEGEncoderInputType;

    // 图像数据（仅当使用自定义输入缓冲区时有效）
    Image: PByte;

    // 注册的OpenGL纹理（仅当使用OpenGL纹理作为输入时有效）
    Texture: PGPUJPEGOpenGLTexture;
  end;

  // JPEG头类型枚举
  TGPUJPEGHeaderType = (GPUJPEG_HEADER_DEFAULT = 0,
    GPUJPEG_HEADER_JFIF = 1 shl 0, // JFIF头
    GPUJPEG_HEADER_SPIFF = 1 shl 1, // SPIFF头
    GPUJPEG_HEADER_ADOBE = 1 shl 2 // Adobe APP8头
    );

  // 将编码器输入设置为图像数据
  //
  // @param input 编码器输入结构体指针
  // @param image 输入图像数据的指针
  // @return 无返回值（void）

procedure gpujpeg_encoder_input_set_image(input: PGPUJPEGEncoderInput;
  Image: PByte); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_input_set_image';

// 将编码器输入设置为GPU图像数据
//
// @param input 编码器输入结构体指针
// @param image GPU图像数据的指针
// @return 无返回值（void）
procedure gpujpeg_encoder_input_set_gpu_image(input: PGPUJPEGEncoderInput;
  Image: PByte); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_input_set_gpu_image';

// 将编码器输入设置为OpenGL纹理
//
// @param input 编码器输入结构体指针
// @param texture OpenGL纹理ID对应的结构体指针
// @return 无返回值（void）
procedure gpujpeg_encoder_input_set_texture(input: PGPUJPEGEncoderInput;
  Texture: PGPUJPEGOpenGLTexture); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_input_set_texture';

// 创建JPEG编码器
//
// @param stream 将要使用的CUDA流，可以是cudaStreamDefault（0x00）
// @return 成功时返回编码器结构体指针，否则返回NULL
function gpujpeg_encoder_create(stream: cudaStream_t): TGPUJPEGEncoder; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_create';

// 计算给定内存大小下能够编码的最大图像像素数（宽度 x 高度）。
//
// @param param 编码参数结构体指针
// @param param_image 图像数据参数结构体指针
// @param image_input_type 图像输入类型枚举值
// @param memory_size 给定的设备内存量
// @param max_pixels 指针，用于接收计算得出的最大像素数
// @return 成功时返回已使用的设备内存大小（以字节为单位），否则返回0
function gpujpeg_encoder_max_pixels(param: PGPUJPEGParameters;
  param_image: PGPUJPEGImageParameters;
  image_input_type: TGPUJPEGEncoderInputType; memory_size: NativeUInt;
  var max_pixels: Integer): NativeUInt; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_max_pixels';

// 计算用于编码指定像素数量图像所需的设备内存最大大小。
//
// @param param 编码参数结构体指针
// @param param_image 图像数据参数结构体指针
// @param image_input_type 图像输入类型枚举值
// @param max_pixels 指定的最大像素数量
// @return 成功时返回以字节为单位的所需设备内存量，否则返回0
function gpujpeg_encoder_max_memory(param: PGPUJPEGParameters;
  param_image: PGPUJPEGImageParameters;
  image_input_type: TGPUJPEGEncoderInputType; max_pixels: Integer): NativeUInt;
  cdecl; external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_max_memory';

// 预先为给定图像像素分配所有编码缓冲区。
//
// @param encoder 编码器结构体指针
// @param param 编码参数结构体指针（常量）
// @param param_image 图像数据参数结构体指针（常量）
// @param image_input_type 图像输入类型枚举值
// @return 成功时返回0，否则返回非零值
function gpujpeg_encoder_allocate(encoder: TGPUJPEGEncoder;
  param: PGPUJPEGParameters; param_image: PGPUJPEGImageParameters;
  image_input_type: TGPUJPEGEncoderInputType): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_allocate';

// 使用编码器压缩图像
//
// @param encoder 编码器结构体指针
// @param param 编码参数结构体指针
// @param param_image 图像数据参数结构体指针
// @param input 源图像数据输入结构体指针
// @param image_compressed 压缩后图像数据缓冲区的变量地址指针，压缩后的图像数据将被放置在此处
// @param image_compressed_size 压缩后图像大小的变量地址指针。该缓冲区由编码器管理，调用者不应释放。
// 缓冲区在下一次调用 gpujpeg_encoder_encode() 之前有效。
// @return 成功时返回0，否则返回非零值
function gpujpeg_encoder_encode(encoder: TGPUJPEGEncoder;
  param: PGPUJPEGParameters; param_image: PGPUJPEGImageParameters;
  input: PGPUJPEGEncoderInput; var image_compressed: PByte;
  var image_compressed_size: NativeUInt): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_encode';

// 返回上次编码图像的持续时间统计信息
// @return 成功时返回0，否则返回非零值
// @note
// 这些值仅为提供信息和调试用途，并不被视为公共API的一部分。
function gpujpeg_encoder_get_stats(encoder: TGPUJPEGEncoder;
  stats: PGPUJPEGDurationStats): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_get_stats';

// 强制输出JPEG头。
//
// 头部类型应能够描述生成的JPEG图像，例如仅对于BT.601全范围YCbCr图像使用JFIF。如果不满足，则生成的JPEG图像可能与解码器不兼容。
procedure gpujpeg_encoder_set_jpeg_header(encoder: TGPUJPEGEncoder;
  header_type: TGPUJPEGHeaderType); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_set_jpeg_header';

// 提供针对指定param_image参数建议的最佳重置间隔，以平衡图像大小和性能。
// @param subsampling 采样模式，可以是444、422或420
function gpujpeg_encoder_suggest_restart_interval
  (param_image: PGPUJPEGImageParameters; subsampling: Integer;
  interleaved: Boolean; verbose: Boolean): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_suggest_restart_interval';

// 销毁JPEG编码器
function gpujpeg_encoder_destroy(encoder: TGPUJPEGEncoder): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_destroy';

implementation

end.
