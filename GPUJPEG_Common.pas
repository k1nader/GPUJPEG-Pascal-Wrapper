unit GPUJPEG_Common;

interface

uses
  System.SysUtils, System.Classes, GPUJPEG_Type;

const
  GPUJPEG_LIBRARY_NAME = 'gpujpeg.dll';

const
  // 获取设备信息时的最大设备数
  GPUJPEG_MAX_DEVICE_COUNT = 10;

  // IDCT 块尺寸
  GPUJPEG_IDCT_BLOCK_X = 8;
  GPUJPEG_IDCT_BLOCK_Y = 8;
  GPUJPEG_IDCT_BLOCK_Z = 2;

  GPUJPEG_SUBSAMPLING_444 = 444;
  GPUJPEG_SUBSAMPLING_422 = 422;
  GPUJPEG_SUBSAMPLING_420 = 420;

type
  CUstream_st = Pointer;
  cudaStream_t = ^CUstream_st;

  TGPUJPEGDeviceInfo = record
    // 设备ID
    id: Integer;
    // 设备名称
    name: array [0 .. 255] of AnsiChar; // 或 WideChar，取决于字符集需求
    // 计算能力主版本号
    cc_major: Integer;
    // 计算能力次版本号
    cc_minor: Integer;
    // 全局内存大小
    global_memory: NativeUInt; // 使用NativeUInt代替size_t
    // 常量内存大小
    constant_memory: NativeUInt;
    // 共享内存大小
    shared_memory: NativeUInt;
    // 每块的寄存器数量
    register_count: Integer;
    // 多处理器数量
    multiprocessor_count: Integer;
  end;

  // 所有设备的信息结构体
  TGPUJPEGDevicesInfo = record
    // 设备数量
    device_count: Integer;
    // 每个设备的信息
    device: array [0 .. GPUJPEG_MAX_DEVICE_COUNT - 1] of TGPUJPEGDeviceInfo;
  end;

  PGPUJPEGParameters = ^TGPUJPEGParameters;

  TGPUJPEGParameters = record
    // 详细级别 - 显示更多信息，收集各阶段的持续时间等
    // 0 - 正常, 1 - 详细, 2 - 调试, 3 - 调试2 (若未定义 NDEBUG)
    verbose: Integer;
    perf_stats: Integer; // 记录性能统计信息，设置为1以允许调用 gpujpeg_encoder_get_stats()

    // 编码质量等级（0-100）
    quality: Integer;

    // 重启间隔（0表示禁用重启间隔并使用CPU霍夫曼编码器）
    restart_interval: Integer;

    // 标志位，决定是否使用交错格式的JPEG流
    // "1" 表示只包含所有颜色分量的一个扫描（例如 Y Cb Cr Y Cb Cr ...），
    // "0" 表示每个颜色分量一个扫描（例如 Y Y Y ..., Cb Cb Cb ..., Cr Cr Cr ...)
    interleaved: Integer;

    // 在流中使用段信息以便快速解码。段信息被放置到特殊的应用程序头中，并包含流中各个段开始处的索引，
    // 因此解码器无需逐字节解析流，只需读取段信息并开始解码即可。对于每个扫描都提供段信息，
    // 当与 "interleaved = 1" 设置结合使用时，可以获得最佳效果。
    segment_info: Integer;

    // JPEG流中每个颜色分量的采样因子数组
    sampling_factor: array [0 .. GPUJPEG_MAX_COMPONENT_COUNT - 1]
      of TGPUJPEGComponentSamplingFactor;

    // 在JPEG流内部使用的颜色空间，即输入数据转换成的颜色空间（默认值为JPEG YCbCr）
    color_space_internal: TGPUJPEGColorSpace;
  end;

  // 图像参数结构体。不应仅通过手动初始化，而应首先调用gpujpeg_image_set_default_parameters函数，
  // 然后根据需要更改部分参数。
  PGPUJPEGImageParameters = ^TGPUJPEGImageParameters;

  TGPUJPEGImageParameters = record
    // 图像数据宽度
    width: Integer;
    // 图像数据高度
    height: Integer;
    // 图像数据组件数量
    comp_count: Integer;
    // 图像数据颜色空间
    color_space: TGPUJPEGColorSpace;
    // 图像数据采样因子
    pixel_format: TGPUJPEGPixelFormat;
  end;

  // 图像文件格式枚举
  TGPUJPEGImageFileFormat = (
    // 未知图像文件格式
    GPUJPEG_IMAGE_FILE_UNKNOWN = 0,
    // JPEG文件格式
    GPUJPEG_IMAGE_FILE_JPEG = 1,
    // 原始文件格式
    // @note 以下所有格式必须是原始格式
    GPUJPEG_IMAGE_FILE_RAW = 2,
    // 灰度文件格式
    GPUJPEG_IMAGE_FILE_GRAY,
    // RGB文件格式，无头简单数据格式 [R G B] [R G B] ...
    GPUJPEG_IMAGE_FILE_RGB,
    // RGBA文件格式，无头简单数据格式 [R G B A] [R G B A] ...
    GPUJPEG_IMAGE_FILE_RGBA,
    // RGBZ文件格式，无头简单数据格式 [R G B 0] [R G B 0] ...
    GPUJPEG_IMAGE_FILE_RGBZ,
    // PNM文件格式
    GPUJPEG_IMAGE_FILE_PGM, GPUJPEG_IMAGE_FILE_PPM, GPUJPEG_IMAGE_FILE_PNM,
    // PAM文件格式
    GPUJPEG_IMAGE_FILE_PAM, GPUJPEG_IMAGE_FILE_Y4M,
    // YUV文件格式，无头简单数据格式 [Y U V] [Y U V] ...
    // @note 以下所有格式必须是YUV
    GPUJPEG_IMAGE_FILE_YUV,
    // YUV带Alpha通道的文件格式 [Y U V A] [Y U V A] ...
    GPUJPEG_IMAGE_FILE_YUVA,
    // i420文件格式
    GPUJPEG_IMAGE_FILE_I420);

  // 编码器/解码器细粒度统计，包含JPEG压缩/解压缩各步骤的持续时间（单位：毫秒）。
  //
  // @注意
  // 这些值仅用于信息展示和调试目的，因此不被视为公共API的一部分。
  PGPUJPEGDurationStats = ^TGPUJPEGDurationStats;

  TGPUJPEGDurationStats = record
    duration_memory_to: Double; // 内存至...
    duration_memory_from: Double; // ...内存的时间
    duration_memory_map: Double; // 内存映射的时间
    duration_memory_unmap: Double; // 内存取消映射的时间
    duration_preprocessor: Double; // 预处理器阶段的持续时间
    duration_dct_quantization: Double; // DCT与量化阶段的持续时间
    duration_huffman_coder: Double; // 霍夫曼编码阶段的持续时间
    duration_stream: Double; // 流处理阶段的持续时间
    duration_in_gpu: Double; // GPU内部处理总时长
  end;

  PGPUJPEGOpenGLContext = ^TGPUJPEGOpenGLContext;

  TGPUJPEGOpenGLContext = Pointer;

  // 已注册的OpenGL纹理类型枚举
  TGPUJPEGOpenGLTextureType = (GPUJPEG_OPENGL_TEXTURE_READ = 1, // 可读纹理
    GPUJPEG_OPENGL_TEXTURE_WRITE = 2 // 可写纹理
    );

  // 表示注册到CUDA的OpenGL纹理，
  // 因此可以获取到设备指针。
  PGPUJPEGOpenGLTexture = ^TGPUJPEGOpenGLTexture;

  TGPUJPEGOpenGLTexture = record
    // 纹理ID
    texture_id: Integer;
    // 纹理类型
    texture_type: TGPUJPEGOpenGLTextureType;
    // 纹理宽度
    texture_width: Integer;
    // 纹理高度
    texture_height: Integer;
    // 纹理像素缓冲对象类型
    texture_pbo_type: Integer;
    // 纹理像素缓冲对象ID
    texture_pbo_id: Integer;
    // 纹理PBO在CUDA中的资源指针
    texture_pbo_resource: Pointer;

    // 纹理回调参数
    texture_callback_param: Pointer;
    // 纹理回调：用于连接OpenGL上下文（默认不使用）
    texture_callback_attach_opengl: procedure(param: Pointer); cdecl;
    // 纹理回调：用于断开OpenGL上下文（默认不使用）
    texture_callback_detach_opengl: procedure(param: Pointer); cdecl;

    // 如果你正在开发一个多线程应用，其中一个线程使用CUDA进行JPEG解码，
    // 另一个线程使用OpenGL显示解码器的输出结果。当图像被解码时，你需要从显示线程中断开OpenGL上下文，
    // 并将其连接到压缩线程（在texture_callback_attach_opengl回调函数内部自动调用）。
    // 解码器然后能够将用于压缩的GPU内存中的数据复制到由OpenGL纹理用于显示的GPU内存中。
    // 然后解码器调用第二个回调函数，你必须从压缩线程断开OpenGL上下文，并将其连接到显示线程（在texture_callback_detach_opengl回调函数内部）。

    // 如果你正在开发单线程应用，其中唯一的线程同时使用CUDA进行压缩和OpenGL进行显示，
    // 则无需实现这些回调函数，因为OpenGL上下文已经与用于JPEG解码的CUDA线程关联。
  end;

  // GPUJPEG库运行时版本
function gpujpeg_version: Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_version';

// 返回GPUJPEG版本号的文本表示形式
function gpujpeg_version_to_string(version: Integer): PAnsiChar; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_version_to_string';

// 返回当前时间（以秒为单位）
function gpujpeg_get_time: Double; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_get_time';

// 获取可用设备信息
// 成功时返回设备信息
function gpujpeg_get_devices_info: TGPUJPEGDevicesInfo; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_get_devices_info';

// 打印可用设备信息
// 成功时返回0，错误时（例如未找到任何设备）返回-1
function gpujpeg_print_devices_info: Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_print_devices_info';

// 初始化CUDA设备
// @param device_id CUDA设备ID（从0开始）
// @param flags 标志位，例如：是否打印设备信息（GPUJPEG_VERBOSE），或启用OpenGL互操作性（GPUJPEG_OPENGL_INTEROPERABILITY）
// 成功时返回0，否则返回非零值
function gpujpeg_init_device(device_id: Integer; flags: Integer): Integer;
  cdecl; external GPUJPEG_LIBRARY_NAME name 'gpujpeg_init_device';

// 设置JPEG编码器的默认参数
// @param param JPEG编码器参数
// @return 无返回值
procedure gpujpeg_set_default_parameters(var param: TGPUJPEGParameters); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_set_default_parameters';

// 设置指定的色度子采样参数
// @param param       编码器参数
// @param subsampling 子采样模式，应为 GPUJPEG_SUBSAMPLING_{444, 422, 420} 中的一个值
procedure gpujpeg_parameters_chroma_subsampling(var param: TGPUJPEGParameters;
  subsampling: Integer); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_parameters_chroma_subsampling';

// @deprecated 使用 gpujpeg_parameters_chroma_subsampling() 函数代替
procedure gpujpeg_parameters_chroma_subsampling_422
  (var param: TGPUJPEGParameters); cdecl; deprecated;
  external GPUJPEG_LIBRARY_NAME name
  'gpujpeg_parameters_chroma_subsampling_422';

// @deprecated 使用 gpujpeg_parameters_chroma_subsampling() 函数代替
procedure gpujpeg_parameters_chroma_subsampling_420
  (var param: TGPUJPEGParameters); cdecl; deprecated;
  external GPUJPEG_LIBRARY_NAME name
  'gpujpeg_parameters_chroma_subsampling_420';

// 返回子采样的友好名称（如4:2:0等）。如果无法构造，则返回W1xH1:W2xH2:W3xH3格式的名称。
function gpujpeg_subsampling_get_name(comp_count: Integer;
  const sampling_factor: PGPUJPEGComponentSamplingFactor): PAnsiChar; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_subsampling_get_name';

// 设置JPEG图像的默认参数
// @param param 图像参数
// @return 无返回值
procedure gpujpeg_image_set_default_parameters
  (var param: TGPUJPEGImageParameters); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_set_default_parameters';

// 从文件名获取图像文件格式
//
// @param filename 图像文件的文件名
// @return 返回图像文件格式或GPUJPEG_IMAGE_FILE_UNKNOWN（如果无法确定类型）
function gpujpeg_image_get_file_format(const filename: PAnsiChar)
  : TGPUJPEGImageFileFormat; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_get_file_format';

// 设置CUDA设备。
//
// @param index 要激活的CUDA设备索引。
procedure gpujpeg_set_device(index: Integer); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_set_device';

// 根据参数计算图像大小
//
// @param param 图像参数结构体指针
// @return 计算得到的图像大小（以字节为单位）
function gpujpeg_image_calculate_size(param: PGPUJPEGImageParameters)
  : NativeUInt; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_calculate_size';

// 从文件加载图像
//
// 分配的图像数据必须通过gpujpeg_image_free()释放。
//
// @param filename          图像文件名
// @param[out] image        分配为CUDA主机缓冲区的图像数据缓冲区指针
// @param[in,out] image_size 图像数据缓冲区大小（可以指定用于验证或设置为0以获取实际大小）
// @return 成功返回0，否则返回非零值
function gpujpeg_image_load_from_file(const filename: PAnsiChar;
  var image: PByte; var image_size: NativeUInt): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_load_from_file';

// 将RGB图像保存到文件
//
// @param filename     图像文件名
// @param image        图像数据缓冲区
// @param image_size   图像数据缓冲区大小
// @param param_image  图像属性结构体指针（可以为NULL）
// @return 成功返回0，否则返回非零值
function gpujpeg_image_save_to_file(const filename: PAnsiChar; image: PByte;
  image_size: NativeUInt; const param_image: PGPUJPEGImageParameters): Integer;
  cdecl; external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_save_to_file';

// 从未压缩文件（如PNM等）读取/获取属性
//
// 对于原始文件，仅根据文件扩展名推断像素格式。
//
// `gpujpeg_image_parameters::comp_size`不由该函数设置，应从pixel_format推断得出。
//
// 当文件不存在但可以从扩展名推断颜色空间时，可能返回一些空值。
// @retval 成功时返回0; 出错时返回非零值
// @retval -1 表示错误
// @retval 1 表示仅从文件扩展名推断出像素格式
function gpujpeg_image_get_properties(const filename: PAnsiChar;
  var param_image: TGPUJPEGImageParameters; file_exists: Integer): Integer;
  cdecl; external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_get_properties';

// 销毁由GPUJPEG分配的图像（例如通过gpujpeg_image_load_from_file()）
//
// @param image 图像数据缓冲区
// @return 成功时返回0，否则返回非零值
function gpujpeg_image_destroy(image: PByte): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_destroy';

// 打印图像样本的范围信息
//
// @param filename 文件名
// @param width 图像宽度
// @param height 图像高度
// @param sampling_factor 像素格式枚举
procedure gpujpeg_image_range_info(const filename: PAnsiChar;
  width, height: Integer; sampling_factor: TGPUJPEGPixelFormat); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_range_info';

// 转换图像
//
// @note 目前不可用
//
// @param input 输入文件名
// @param output 输出文件名
// @param param_image_from 源图像参数结构体
// @param param_image_to 目标图像参数结构体
// @return 成功时返回0，否则返回非零值
function gpujpeg_image_convert(const input, output: PAnsiChar;
  param_image_from, param_image_to: TGPUJPEGImageParameters): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_convert';

// 初始化OpenGL上下文
//
// 此调用是可选的 - 如果已经存在OpenGL上下文，则无需调用。如果不调用此函数，
// 则在使用与GL互操作性运行GPUJPEG之前可能需要在客户端代码中先运行glewInit()。
//
// 当完成时，返回的指针应通过gpujpeg_opengl_destroy()释放。
//
// @param[out] ctx 指向OpenGL上下文数据的指针（传递给gpujpeg_opengl_destroy()）
// @return 成功时返回0，否则返回非零值
// @return -1 初始化失败
// @return -2 未编译OpenGL支持
function gpujpeg_opengl_init(var ctx: PGPUJPEGOpenGLContext): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_init';

// 销毁通过gpujpeg_opengl_init()创建的OpenGL上下文
//
// @param ctx 由gpujpeg_opengl_init()创建并返回的OpenGL上下文指针
procedure gpujpeg_opengl_destroy(ctx: PGPUJPEGOpenGLContext); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_destroy';

// 创建OpenGL纹理
//
// @param width 纹理宽度
// @param height 纹理高度
// @param data 指向纹理数据的指针
// @return 成功时返回非零纹理ID，否则返回0
function gpujpeg_opengl_texture_create(width, height: Integer; data: PByte)
  : Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_texture_create';

// 设置OpenGL纹理数据
//
// @param texture_id 纹理ID
// @param data 指向纹理数据的指针
// @return 成功时返回0，否则返回非零值
function gpujpeg_opengl_texture_set_data(texture_id: Integer; data: PByte)
  : Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_texture_set_data';

// 从OpenGL纹理获取数据
//
// @param texture_id 纹理ID
// @param data 指向用于接收纹理数据的缓冲区指针
// @param data_size 指向一个变量，用于存储实际读取的数据大小（输入时为缓冲区大小，输出时为实际数据大小）
// @return 成功时返回0，否则返回非零值
function gpujpeg_opengl_texture_get_data(texture_id: Integer; data: PByte;
  var data_size: NativeUInt): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_texture_get_data';

// 销毁OpenGL纹理
//
// @param texture_id 纹理ID
procedure gpujpeg_opengl_texture_destroy(texture_id: Integer); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_texture_destroy';

// 将OpenGL纹理注册到CUDA
//
// @param texture_id 纹理ID
// @param texture_type 纹理类型
// @return 分配并注册后的纹理结构体指针
function gpujpeg_opengl_texture_register(texture_id: Integer;
  texture_type: TGPUJPEGOpenGLTextureType): PGPUJPEGOpenGLTexture; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_texture_register';

// 从CUDA中注销OpenGL纹理。同时释放给定结构体。
//
// @param texture 已注册的OpenGL纹理结构体指针
procedure gpujpeg_opengl_texture_unregister(texture: PGPUJPEGOpenGLTexture);
  cdecl; external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_texture_unregister';

// 将已注册的OpenGL纹理映射到CUDA，并返回指向纹理数据的设备指针
//
// @param texture 已注册的OpenGL纹理结构体指针
// @param data_size 返回缓冲区的数据大小（传出参数）
// @param copy_from_texture 指定是否应从纹理执行内存复制操作
// （注：Delphi版API未包含此参数，根据C函数原型推测可能是默认执行复制操作）
function gpujpeg_opengl_texture_map(texture: PGPUJPEGOpenGLTexture;
  var data_size: NativeUInt): PByte; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_texture_map';

// 将已注册的OpenGL纹理从CUDA取消映射，之后设备指针将不再可用。
//
// @param texture 已注册的OpenGL纹理结构体指针
// @param copy_to_texture 指定是否应执行到纹理的内存复制操作
// （注：Delphi版API未包含此参数，根据C函数原型推测可能是默认执行复制操作）
procedure gpujpeg_opengl_texture_unmap(texture: PGPUJPEGOpenGLTexture); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_texture_unmap';

// 获取颜色空间名称
//
// @param color_space 颜色空间枚举值
function gpujpeg_color_space_get_name(color_space: TGPUJPEGColorSpace)
  : PAnsiChar; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_color_space_get_name';

// 通过字符串名称返回像素格式
function gpujpeg_pixel_format_by_name(name: PAnsiChar): TGPUJPEGPixelFormat;
  cdecl; external GPUJPEG_LIBRARY_NAME name 'gpujpeg_pixel_format_by_name';

// 返回像素格式中颜色分量的数量
function gpujpeg_pixel_format_get_comp_count(pixel_format: TGPUJPEGPixelFormat)
  : Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_pixel_format_get_comp_count';

// 返回像素格式的名称
function gpujpeg_pixel_format_get_name(pixel_format: TGPUJPEGPixelFormat)
  : PAnsiChar; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_pixel_format_get_name';

// 判断像素格式是否为平面格式（planar）
function gpujpeg_pixel_format_is_planar(pixel_format: TGPUJPEGPixelFormat)
  : Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_pixel_format_is_planar';

// 返回444、422或420子采样模式
function gpujpeg_pixel_format_get_subsampling(pixel_format: TGPUJPEGPixelFormat)
  : Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_pixel_format_get_subsampling';

implementation

end.
