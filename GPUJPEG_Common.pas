unit GPUJPEG_Common;

interface

uses
  System.SysUtils, System.Classes, GPUJPEG_Type;

const
  GPUJPEG_LIBRARY_NAME = 'gpujpeg.dll';

const
  // ��ȡ�豸��Ϣʱ������豸��
  GPUJPEG_MAX_DEVICE_COUNT = 10;

  // IDCT ��ߴ�
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
    // �豸ID
    id: Integer;
    // �豸����
    name: array [0 .. 255] of AnsiChar; // �� WideChar��ȡ�����ַ�������
    // �����������汾��
    cc_major: Integer;
    // ���������ΰ汾��
    cc_minor: Integer;
    // ȫ���ڴ��С
    global_memory: NativeUInt; // ʹ��NativeUInt����size_t
    // �����ڴ��С
    constant_memory: NativeUInt;
    // �����ڴ��С
    shared_memory: NativeUInt;
    // ÿ��ļĴ�������
    register_count: Integer;
    // �ദ��������
    multiprocessor_count: Integer;
  end;

  // �����豸����Ϣ�ṹ��
  TGPUJPEGDevicesInfo = record
    // �豸����
    device_count: Integer;
    // ÿ���豸����Ϣ
    device: array [0 .. GPUJPEG_MAX_DEVICE_COUNT - 1] of TGPUJPEGDeviceInfo;
  end;

  PGPUJPEGParameters = ^TGPUJPEGParameters;

  TGPUJPEGParameters = record
    // ��ϸ���� - ��ʾ������Ϣ���ռ����׶εĳ���ʱ���
    // 0 - ����, 1 - ��ϸ, 2 - ����, 3 - ����2 (��δ���� NDEBUG)
    verbose: Integer;
    perf_stats: Integer; // ��¼����ͳ����Ϣ������Ϊ1��������� gpujpeg_encoder_get_stats()

    // ���������ȼ���0-100��
    quality: Integer;

    // ���������0��ʾ�������������ʹ��CPU��������������
    restart_interval: Integer;

    // ��־λ�������Ƿ�ʹ�ý����ʽ��JPEG��
    // "1" ��ʾֻ����������ɫ������һ��ɨ�裨���� Y Cb Cr Y Cb Cr ...����
    // "0" ��ʾÿ����ɫ����һ��ɨ�裨���� Y Y Y ..., Cb Cb Cb ..., Cr Cr Cr ...)
    interleaved: Integer;

    // ������ʹ�ö���Ϣ�Ա���ٽ��롣����Ϣ�����õ������Ӧ�ó���ͷ�У����������и����ο�ʼ����������
    // ��˽������������ֽڽ�������ֻ���ȡ����Ϣ����ʼ���뼴�ɡ�����ÿ��ɨ�趼�ṩ����Ϣ��
    // ���� "interleaved = 1" ���ý��ʹ��ʱ�����Ի�����Ч����
    segment_info: Integer;

    // JPEG����ÿ����ɫ�����Ĳ�����������
    sampling_factor: array [0 .. GPUJPEG_MAX_COMPONENT_COUNT - 1]
      of TGPUJPEGComponentSamplingFactor;

    // ��JPEG���ڲ�ʹ�õ���ɫ�ռ䣬����������ת���ɵ���ɫ�ռ䣨Ĭ��ֵΪJPEG YCbCr��
    color_space_internal: TGPUJPEGColorSpace;
  end;

  // ͼ������ṹ�塣��Ӧ��ͨ���ֶ���ʼ������Ӧ���ȵ���gpujpeg_image_set_default_parameters������
  // Ȼ�������Ҫ���Ĳ��ֲ�����
  PGPUJPEGImageParameters = ^TGPUJPEGImageParameters;

  TGPUJPEGImageParameters = record
    // ͼ�����ݿ��
    width: Integer;
    // ͼ�����ݸ߶�
    height: Integer;
    // ͼ�������������
    comp_count: Integer;
    // ͼ��������ɫ�ռ�
    color_space: TGPUJPEGColorSpace;
    // ͼ�����ݲ�������
    pixel_format: TGPUJPEGPixelFormat;
  end;

  // ͼ���ļ���ʽö��
  TGPUJPEGImageFileFormat = (
    // δ֪ͼ���ļ���ʽ
    GPUJPEG_IMAGE_FILE_UNKNOWN = 0,
    // JPEG�ļ���ʽ
    GPUJPEG_IMAGE_FILE_JPEG = 1,
    // ԭʼ�ļ���ʽ
    // @note �������и�ʽ������ԭʼ��ʽ
    GPUJPEG_IMAGE_FILE_RAW = 2,
    // �Ҷ��ļ���ʽ
    GPUJPEG_IMAGE_FILE_GRAY,
    // RGB�ļ���ʽ����ͷ�����ݸ�ʽ [R G B] [R G B] ...
    GPUJPEG_IMAGE_FILE_RGB,
    // RGBA�ļ���ʽ����ͷ�����ݸ�ʽ [R G B A] [R G B A] ...
    GPUJPEG_IMAGE_FILE_RGBA,
    // RGBZ�ļ���ʽ����ͷ�����ݸ�ʽ [R G B 0] [R G B 0] ...
    GPUJPEG_IMAGE_FILE_RGBZ,
    // PNM�ļ���ʽ
    GPUJPEG_IMAGE_FILE_PGM, GPUJPEG_IMAGE_FILE_PPM, GPUJPEG_IMAGE_FILE_PNM,
    // PAM�ļ���ʽ
    GPUJPEG_IMAGE_FILE_PAM, GPUJPEG_IMAGE_FILE_Y4M,
    // YUV�ļ���ʽ����ͷ�����ݸ�ʽ [Y U V] [Y U V] ...
    // @note �������и�ʽ������YUV
    GPUJPEG_IMAGE_FILE_YUV,
    // YUV��Alphaͨ�����ļ���ʽ [Y U V A] [Y U V A] ...
    GPUJPEG_IMAGE_FILE_YUVA,
    // i420�ļ���ʽ
    GPUJPEG_IMAGE_FILE_I420);

  // ������/������ϸ����ͳ�ƣ�����JPEGѹ��/��ѹ��������ĳ���ʱ�䣨��λ�����룩��
  //
  // @ע��
  // ��Щֵ��������Ϣչʾ�͵���Ŀ�ģ���˲�����Ϊ����API��һ���֡�
  PGPUJPEGDurationStats = ^TGPUJPEGDurationStats;

  TGPUJPEGDurationStats = record
    duration_memory_to: Double; // �ڴ���...
    duration_memory_from: Double; // ...�ڴ��ʱ��
    duration_memory_map: Double; // �ڴ�ӳ���ʱ��
    duration_memory_unmap: Double; // �ڴ�ȡ��ӳ���ʱ��
    duration_preprocessor: Double; // Ԥ�������׶εĳ���ʱ��
    duration_dct_quantization: Double; // DCT�������׶εĳ���ʱ��
    duration_huffman_coder: Double; // ����������׶εĳ���ʱ��
    duration_stream: Double; // ������׶εĳ���ʱ��
    duration_in_gpu: Double; // GPU�ڲ�������ʱ��
  end;

  PGPUJPEGOpenGLContext = ^TGPUJPEGOpenGLContext;

  TGPUJPEGOpenGLContext = Pointer;

  // ��ע���OpenGL��������ö��
  TGPUJPEGOpenGLTextureType = (GPUJPEG_OPENGL_TEXTURE_READ = 1, // �ɶ�����
    GPUJPEG_OPENGL_TEXTURE_WRITE = 2 // ��д����
    );

  // ��ʾע�ᵽCUDA��OpenGL����
  // ��˿��Ի�ȡ���豸ָ�롣
  PGPUJPEGOpenGLTexture = ^TGPUJPEGOpenGLTexture;

  TGPUJPEGOpenGLTexture = record
    // ����ID
    texture_id: Integer;
    // ��������
    texture_type: TGPUJPEGOpenGLTextureType;
    // ������
    texture_width: Integer;
    // ����߶�
    texture_height: Integer;
    // �������ػ����������
    texture_pbo_type: Integer;
    // �������ػ������ID
    texture_pbo_id: Integer;
    // ����PBO��CUDA�е���Դָ��
    texture_pbo_resource: Pointer;

    // ����ص�����
    texture_callback_param: Pointer;
    // ����ص�����������OpenGL�����ģ�Ĭ�ϲ�ʹ�ã�
    texture_callback_attach_opengl: procedure(param: Pointer); cdecl;
    // ����ص������ڶϿ�OpenGL�����ģ�Ĭ�ϲ�ʹ�ã�
    texture_callback_detach_opengl: procedure(param: Pointer); cdecl;

    // ��������ڿ���һ�����߳�Ӧ�ã�����һ���߳�ʹ��CUDA����JPEG���룬
    // ��һ���߳�ʹ��OpenGL��ʾ������������������ͼ�񱻽���ʱ������Ҫ����ʾ�߳��жϿ�OpenGL�����ģ�
    // ���������ӵ�ѹ���̣߳���texture_callback_attach_opengl�ص������ڲ��Զ����ã���
    // ������Ȼ���ܹ�������ѹ����GPU�ڴ��е����ݸ��Ƶ���OpenGL����������ʾ��GPU�ڴ��С�
    // Ȼ����������õڶ����ص�������������ѹ���̶߳Ͽ�OpenGL�����ģ����������ӵ���ʾ�̣߳���texture_callback_detach_opengl�ص������ڲ�����

    // ��������ڿ������߳�Ӧ�ã�����Ψһ���߳�ͬʱʹ��CUDA����ѹ����OpenGL������ʾ��
    // ������ʵ����Щ�ص���������ΪOpenGL�������Ѿ�������JPEG�����CUDA�̹߳�����
  end;

  // GPUJPEG������ʱ�汾
function gpujpeg_version: Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_version';

// ����GPUJPEG�汾�ŵ��ı���ʾ��ʽ
function gpujpeg_version_to_string(version: Integer): PAnsiChar; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_version_to_string';

// ���ص�ǰʱ�䣨����Ϊ��λ��
function gpujpeg_get_time: Double; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_get_time';

// ��ȡ�����豸��Ϣ
// �ɹ�ʱ�����豸��Ϣ
function gpujpeg_get_devices_info: TGPUJPEGDevicesInfo; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_get_devices_info';

// ��ӡ�����豸��Ϣ
// �ɹ�ʱ����0������ʱ������δ�ҵ��κ��豸������-1
function gpujpeg_print_devices_info: Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_print_devices_info';

// ��ʼ��CUDA�豸
// @param device_id CUDA�豸ID����0��ʼ��
// @param flags ��־λ�����磺�Ƿ��ӡ�豸��Ϣ��GPUJPEG_VERBOSE����������OpenGL�������ԣ�GPUJPEG_OPENGL_INTEROPERABILITY��
// �ɹ�ʱ����0�����򷵻ط���ֵ
function gpujpeg_init_device(device_id: Integer; flags: Integer): Integer;
  cdecl; external GPUJPEG_LIBRARY_NAME name 'gpujpeg_init_device';

// ����JPEG��������Ĭ�ϲ���
// @param param JPEG����������
// @return �޷���ֵ
procedure gpujpeg_set_default_parameters(var param: TGPUJPEGParameters); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_set_default_parameters';

// ����ָ����ɫ���Ӳ�������
// @param param       ����������
// @param subsampling �Ӳ���ģʽ��ӦΪ GPUJPEG_SUBSAMPLING_{444, 422, 420} �е�һ��ֵ
procedure gpujpeg_parameters_chroma_subsampling(var param: TGPUJPEGParameters;
  subsampling: Integer); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_parameters_chroma_subsampling';

// @deprecated ʹ�� gpujpeg_parameters_chroma_subsampling() ��������
procedure gpujpeg_parameters_chroma_subsampling_422
  (var param: TGPUJPEGParameters); cdecl; deprecated;
  external GPUJPEG_LIBRARY_NAME name
  'gpujpeg_parameters_chroma_subsampling_422';

// @deprecated ʹ�� gpujpeg_parameters_chroma_subsampling() ��������
procedure gpujpeg_parameters_chroma_subsampling_420
  (var param: TGPUJPEGParameters); cdecl; deprecated;
  external GPUJPEG_LIBRARY_NAME name
  'gpujpeg_parameters_chroma_subsampling_420';

// �����Ӳ������Ѻ����ƣ���4:2:0�ȣ�������޷����죬�򷵻�W1xH1:W2xH2:W3xH3��ʽ�����ơ�
function gpujpeg_subsampling_get_name(comp_count: Integer;
  const sampling_factor: PGPUJPEGComponentSamplingFactor): PAnsiChar; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_subsampling_get_name';

// ����JPEGͼ���Ĭ�ϲ���
// @param param ͼ�����
// @return �޷���ֵ
procedure gpujpeg_image_set_default_parameters
  (var param: TGPUJPEGImageParameters); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_set_default_parameters';

// ���ļ�����ȡͼ���ļ���ʽ
//
// @param filename ͼ���ļ����ļ���
// @return ����ͼ���ļ���ʽ��GPUJPEG_IMAGE_FILE_UNKNOWN������޷�ȷ�����ͣ�
function gpujpeg_image_get_file_format(const filename: PAnsiChar)
  : TGPUJPEGImageFileFormat; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_get_file_format';

// ����CUDA�豸��
//
// @param index Ҫ�����CUDA�豸������
procedure gpujpeg_set_device(index: Integer); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_set_device';

// ���ݲ�������ͼ���С
//
// @param param ͼ������ṹ��ָ��
// @return ����õ���ͼ���С�����ֽ�Ϊ��λ��
function gpujpeg_image_calculate_size(param: PGPUJPEGImageParameters)
  : NativeUInt; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_calculate_size';

// ���ļ�����ͼ��
//
// �����ͼ�����ݱ���ͨ��gpujpeg_image_free()�ͷš�
//
// @param filename          ͼ���ļ���
// @param[out] image        ����ΪCUDA������������ͼ�����ݻ�����ָ��
// @param[in,out] image_size ͼ�����ݻ�������С������ָ��������֤������Ϊ0�Ի�ȡʵ�ʴ�С��
// @return �ɹ�����0�����򷵻ط���ֵ
function gpujpeg_image_load_from_file(const filename: PAnsiChar;
  var image: PByte; var image_size: NativeUInt): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_load_from_file';

// ��RGBͼ�񱣴浽�ļ�
//
// @param filename     ͼ���ļ���
// @param image        ͼ�����ݻ�����
// @param image_size   ͼ�����ݻ�������С
// @param param_image  ͼ�����Խṹ��ָ�루����ΪNULL��
// @return �ɹ�����0�����򷵻ط���ֵ
function gpujpeg_image_save_to_file(const filename: PAnsiChar; image: PByte;
  image_size: NativeUInt; const param_image: PGPUJPEGImageParameters): Integer;
  cdecl; external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_save_to_file';

// ��δѹ���ļ�����PNM�ȣ���ȡ/��ȡ����
//
// ����ԭʼ�ļ����������ļ���չ���ƶ����ظ�ʽ��
//
// `gpujpeg_image_parameters::comp_size`���ɸú������ã�Ӧ��pixel_format�ƶϵó���
//
// ���ļ������ڵ����Դ���չ���ƶ���ɫ�ռ�ʱ�����ܷ���һЩ��ֵ��
// @retval �ɹ�ʱ����0; ����ʱ���ط���ֵ
// @retval -1 ��ʾ����
// @retval 1 ��ʾ�����ļ���չ���ƶϳ����ظ�ʽ
function gpujpeg_image_get_properties(const filename: PAnsiChar;
  var param_image: TGPUJPEGImageParameters; file_exists: Integer): Integer;
  cdecl; external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_get_properties';

// ������GPUJPEG�����ͼ������ͨ��gpujpeg_image_load_from_file()��
//
// @param image ͼ�����ݻ�����
// @return �ɹ�ʱ����0�����򷵻ط���ֵ
function gpujpeg_image_destroy(image: PByte): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_destroy';

// ��ӡͼ�������ķ�Χ��Ϣ
//
// @param filename �ļ���
// @param width ͼ����
// @param height ͼ��߶�
// @param sampling_factor ���ظ�ʽö��
procedure gpujpeg_image_range_info(const filename: PAnsiChar;
  width, height: Integer; sampling_factor: TGPUJPEGPixelFormat); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_range_info';

// ת��ͼ��
//
// @note Ŀǰ������
//
// @param input �����ļ���
// @param output ����ļ���
// @param param_image_from Դͼ������ṹ��
// @param param_image_to Ŀ��ͼ������ṹ��
// @return �ɹ�ʱ����0�����򷵻ط���ֵ
function gpujpeg_image_convert(const input, output: PAnsiChar;
  param_image_from, param_image_to: TGPUJPEGImageParameters): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_image_convert';

// ��ʼ��OpenGL������
//
// �˵����ǿ�ѡ�� - ����Ѿ�����OpenGL�����ģ���������á���������ô˺�����
// ����ʹ����GL������������GPUJPEG֮ǰ������Ҫ�ڿͻ��˴�����������glewInit()��
//
// �����ʱ�����ص�ָ��Ӧͨ��gpujpeg_opengl_destroy()�ͷš�
//
// @param[out] ctx ָ��OpenGL���������ݵ�ָ�루���ݸ�gpujpeg_opengl_destroy()��
// @return �ɹ�ʱ����0�����򷵻ط���ֵ
// @return -1 ��ʼ��ʧ��
// @return -2 δ����OpenGL֧��
function gpujpeg_opengl_init(var ctx: PGPUJPEGOpenGLContext): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_init';

// ����ͨ��gpujpeg_opengl_init()������OpenGL������
//
// @param ctx ��gpujpeg_opengl_init()���������ص�OpenGL������ָ��
procedure gpujpeg_opengl_destroy(ctx: PGPUJPEGOpenGLContext); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_destroy';

// ����OpenGL����
//
// @param width ������
// @param height ����߶�
// @param data ָ���������ݵ�ָ��
// @return �ɹ�ʱ���ط�������ID�����򷵻�0
function gpujpeg_opengl_texture_create(width, height: Integer; data: PByte)
  : Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_texture_create';

// ����OpenGL��������
//
// @param texture_id ����ID
// @param data ָ���������ݵ�ָ��
// @return �ɹ�ʱ����0�����򷵻ط���ֵ
function gpujpeg_opengl_texture_set_data(texture_id: Integer; data: PByte)
  : Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_texture_set_data';

// ��OpenGL�����ȡ����
//
// @param texture_id ����ID
// @param data ָ�����ڽ����������ݵĻ�����ָ��
// @param data_size ָ��һ�����������ڴ洢ʵ�ʶ�ȡ�����ݴ�С������ʱΪ��������С�����ʱΪʵ�����ݴ�С��
// @return �ɹ�ʱ����0�����򷵻ط���ֵ
function gpujpeg_opengl_texture_get_data(texture_id: Integer; data: PByte;
  var data_size: NativeUInt): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_texture_get_data';

// ����OpenGL����
//
// @param texture_id ����ID
procedure gpujpeg_opengl_texture_destroy(texture_id: Integer); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_texture_destroy';

// ��OpenGL����ע�ᵽCUDA
//
// @param texture_id ����ID
// @param texture_type ��������
// @return ���䲢ע��������ṹ��ָ��
function gpujpeg_opengl_texture_register(texture_id: Integer;
  texture_type: TGPUJPEGOpenGLTextureType): PGPUJPEGOpenGLTexture; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_texture_register';

// ��CUDA��ע��OpenGL����ͬʱ�ͷŸ����ṹ�塣
//
// @param texture ��ע���OpenGL����ṹ��ָ��
procedure gpujpeg_opengl_texture_unregister(texture: PGPUJPEGOpenGLTexture);
  cdecl; external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_texture_unregister';

// ����ע���OpenGL����ӳ�䵽CUDA��������ָ���������ݵ��豸ָ��
//
// @param texture ��ע���OpenGL����ṹ��ָ��
// @param data_size ���ػ����������ݴ�С������������
// @param copy_from_texture ָ���Ƿ�Ӧ������ִ���ڴ渴�Ʋ���
// ��ע��Delphi��APIδ�����˲���������C����ԭ���Ʋ������Ĭ��ִ�и��Ʋ�����
function gpujpeg_opengl_texture_map(texture: PGPUJPEGOpenGLTexture;
  var data_size: NativeUInt): PByte; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_texture_map';

// ����ע���OpenGL�����CUDAȡ��ӳ�䣬֮���豸ָ�뽫���ٿ��á�
//
// @param texture ��ע���OpenGL����ṹ��ָ��
// @param copy_to_texture ָ���Ƿ�Ӧִ�е�������ڴ渴�Ʋ���
// ��ע��Delphi��APIδ�����˲���������C����ԭ���Ʋ������Ĭ��ִ�и��Ʋ�����
procedure gpujpeg_opengl_texture_unmap(texture: PGPUJPEGOpenGLTexture); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_opengl_texture_unmap';

// ��ȡ��ɫ�ռ�����
//
// @param color_space ��ɫ�ռ�ö��ֵ
function gpujpeg_color_space_get_name(color_space: TGPUJPEGColorSpace)
  : PAnsiChar; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_color_space_get_name';

// ͨ���ַ������Ʒ������ظ�ʽ
function gpujpeg_pixel_format_by_name(name: PAnsiChar): TGPUJPEGPixelFormat;
  cdecl; external GPUJPEG_LIBRARY_NAME name 'gpujpeg_pixel_format_by_name';

// �������ظ�ʽ����ɫ����������
function gpujpeg_pixel_format_get_comp_count(pixel_format: TGPUJPEGPixelFormat)
  : Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_pixel_format_get_comp_count';

// �������ظ�ʽ������
function gpujpeg_pixel_format_get_name(pixel_format: TGPUJPEGPixelFormat)
  : PAnsiChar; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_pixel_format_get_name';

// �ж����ظ�ʽ�Ƿ�Ϊƽ���ʽ��planar��
function gpujpeg_pixel_format_is_planar(pixel_format: TGPUJPEGPixelFormat)
  : Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_pixel_format_is_planar';

// ����444��422��420�Ӳ���ģʽ
function gpujpeg_pixel_format_get_subsampling(pixel_format: TGPUJPEGPixelFormat)
  : Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_pixel_format_get_subsampling';

implementation

end.
