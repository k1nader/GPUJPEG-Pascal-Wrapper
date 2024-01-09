unit GPUJPEG_Decoder;

interface

uses
  GPUJPEG_Type, GPUJPEG_Common;

type
  // 解码器结构体（未定义具体成员，仅声明）

  TGPUJPEGDecoder = Pointer;

  // 解码器输出类型枚举
  TGPUJPEGDecoderOutputType = (GPUJPEG_DECODER_OUTPUT_INTERNAL_BUFFER,
    // 使用解码器内部输出缓冲区
    GPUJPEG_DECODER_OUTPUT_CUSTOM_BUFFER, // 使用自定义输出缓冲区
    GPUJPEG_DECODER_OUTPUT_OPENGL_TEXTURE, // 使用OpenGL纹理PBO资源作为输出缓冲区
    GPUJPEG_DECODER_OUTPUT_CUDA_BUFFER, // 使用内部CUDA缓冲区作为输出缓冲区
    GPUJPEG_DECODER_OUTPUT_CUSTOM_CUDA_BUFFER // 使用自定义CUDA缓冲区作为输出缓冲区
    );

  // 解码器输出结构体
  PGPUJPEGDecoderOutput = ^TGPUJPEGDecoderOutput;

  TGPUJPEGDecoderOutput = record
    // 输出类型
    Type_: TGPUJPEGDecoderOutputType;

    // 解压缩后的数据
    Data: PByte;

    // 解压缩后数据大小
    DataSize: NativeUInt;

    // 解码后的颜色空间
    ColorSpace: TGPUJPEGColorSpace;

    // 解码后的像素格式
    PixelFormat: TGPUJPEGPixelFormat;

    // OpenGL纹理
    Texture: PGPUJPEGOpenGLTexture;
  end;

  // 将默认参数设置到解码器输出结构体中
  //
  // @param output 解码器输出结构体指针
procedure gpujpeg_decoder_output_set_default(output: PGPUJPEGDecoderOutput);
  cdecl; external GPUJPEG_LIBRARY_NAME name
  'gpujpeg_decoder_output_set_default';

// 将解码器输出设置为自定义缓冲区
//
// @param output        解码器输出结构体指针
// @param custom_buffer 自定义缓冲区的指针
procedure gpujpeg_decoder_output_set_custom(output: PGPUJPEGDecoderOutput;
  custom_buffer: PByte); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_output_set_custom';

// 将解码器输出设置为OpenGL纹理
//
// @param output 解码器输出结构体指针
// @param texture OpenGL纹理结构体指针
procedure gpujpeg_decoder_output_set_texture(output: PGPUJPEGDecoderOutput;
  Texture: PGPUJPEGOpenGLTexture); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_output_set_texture';

// 将输出设置为CUDA缓冲区
//
// @param output 解码器输出结构体指针
procedure gpujpeg_decoder_output_set_cuda_buffer(output: PGPUJPEGDecoderOutput);
  cdecl; external GPUJPEG_LIBRARY_NAME name
  'gpujpeg_decoder_output_set_cuda_buffer';

// 将解码器输出设置为自定义CUDA缓冲区
//
// @param output          解码器输出结构体指针
// @param d_custom_buffer 设备内存中的自定义缓冲区指针
// @return 无返回值（void）
procedure gpujpeg_decoder_output_set_custom_cuda(output: PGPUJPEGDecoderOutput;
  d_custom_buffer: PByte); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_output_set_custom_cuda';

// 创建JPEG解码器
//
// @param stream 将要使用的CUDA流，可以是cudaStreamDefault（值为0x00）
// @return 成功时返回解码器结构体指针，否则返回NULL
function gpujpeg_decoder_create(stream: cudaStream_t): TGPUJPEGDecoder; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_create';

// 初始化针对特定图像属性的JPEG解码器
//
// 以下属性是相关的：
// - 图像尺寸、组件数量
// - 将要请求的输出像素格式
// - 交错方式、重置间隔、color_space_internal（通常为GPUJPEG_YCBCR_BT601_256LVLS）
// - 正确的子采样设置
//
// @note
// 不需要用户代码调用，解压缩过程中会根据图像属性自动初始化缓冲区。
//
// @param decoder 解码器结构体指针
// @param param 编码参数结构体指针（常量），指向的结构体会被复制
// @param param_image 图像数据参数结构体指针（常量），指向的结构体会被复制
// @return 成功时返回0，否则返回非零值
function gpujpeg_decoder_init(decoder: TGPUJPEGDecoder;
  param: PGPUJPEGParameters; param_image: PGPUJPEGParameters): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_init';

// 使用解码器解压缩图像
//
// @param decoder 解码器结构体指针
// @param image 源图像数据的指针
// @param image_size 源图像数据大小（以字节为单位）
// @param output 输出参数结构体指针，其中包含了指向解压缩后图像数据缓冲区的指针和解压缩图像大小的信息
// @return 成功时返回0，否则返回非零值
function gpujpeg_decoder_decode(decoder: TGPUJPEGDecoder; image: PByte;
  image_size: NativeUInt; output: PGPUJPEGDecoderOutput): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_decode';

// 返回上次解码图像的持续时间统计信息
// @return 成功时返回0，否则返回非零值
// @note
// 这些值仅供提供信息和调试使用，因此不被视为公共API的一部分。
function gpujpeg_decoder_get_stats(decoder: TGPUJPEGDecoder;
  stats: PGPUJPEGDurationStats): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_get_stats';

// 销毁JPEG解码器
//
// @param decoder 解码器结构体指针
// @return 成功销毁时返回0，否则返回非零值
function gpujpeg_decoder_destroy(decoder: TGPUJPEGDecoder): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_destroy';

// 设置输出格式
//
// @param decoder         解码器结构体指针
// @param color_space     请求的输出色彩空间枚举值
// @param sampling_factor 请求的颜色采样因子枚举值
procedure gpujpeg_decoder_set_output_format(decoder: TGPUJPEGDecoder;
  color_space: TGPUJPEGColorSpace; sampling_factor: TGPUJPEGPixelFormat); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_set_output_format';

// 该函数与gpujpeg_reader_get_image_info功能相同
function gpujpeg_decoder_get_image_info(image: PByte; image_size: NativeUInt;
  param_image: PGPUJPEGImageParameters; param: PGPUJPEGParameters;
  var segment_count: Integer): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_get_image_info';

implementation

end.
