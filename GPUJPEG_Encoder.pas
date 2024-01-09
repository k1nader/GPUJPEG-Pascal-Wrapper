unit GPUJPEG_Encoder;

interface

uses
  GPUJPEG_Type, GPUJPEG_Common;

type

  TGPUJPEGEncoder = Pointer;

  // ��������������ö��
  TGPUJPEGEncoderInputType = (GPUJPEG_ENCODER_INPUT_IMAGE, // ʹ���Զ������뻺����
    GPUJPEG_ENCODER_INPUT_OPENGL_TEXTURE, // ʹ��OpenGL����PBO��Դ��Ϊ���뻺����
    GPUJPEG_ENCODER_INPUT_GPU_IMAGE // ʹ���Զ���GPU���뻺����
    );

  // ����������ṹ��
  PGPUJPEGEncoderInput = ^TGPUJPEGEncoderInput;

  TGPUJPEGEncoderInput = record
    // ��������
    Type_: TGPUJPEGEncoderInputType;

    // ͼ�����ݣ�����ʹ���Զ������뻺����ʱ��Ч��
    Image: PByte;

    // ע���OpenGL��������ʹ��OpenGL������Ϊ����ʱ��Ч��
    Texture: PGPUJPEGOpenGLTexture;
  end;

  // JPEGͷ����ö��
  TGPUJPEGHeaderType = (GPUJPEG_HEADER_DEFAULT = 0,
    GPUJPEG_HEADER_JFIF = 1 shl 0, // JFIFͷ
    GPUJPEG_HEADER_SPIFF = 1 shl 1, // SPIFFͷ
    GPUJPEG_HEADER_ADOBE = 1 shl 2 // Adobe APP8ͷ
    );

  // ����������������Ϊͼ������
  //
  // @param input ����������ṹ��ָ��
  // @param image ����ͼ�����ݵ�ָ��
  // @return �޷���ֵ��void��

procedure gpujpeg_encoder_input_set_image(input: PGPUJPEGEncoderInput;
  Image: PByte); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_input_set_image';

// ����������������ΪGPUͼ������
//
// @param input ����������ṹ��ָ��
// @param image GPUͼ�����ݵ�ָ��
// @return �޷���ֵ��void��
procedure gpujpeg_encoder_input_set_gpu_image(input: PGPUJPEGEncoderInput;
  Image: PByte); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_input_set_gpu_image';

// ����������������ΪOpenGL����
//
// @param input ����������ṹ��ָ��
// @param texture OpenGL����ID��Ӧ�Ľṹ��ָ��
// @return �޷���ֵ��void��
procedure gpujpeg_encoder_input_set_texture(input: PGPUJPEGEncoderInput;
  Texture: PGPUJPEGOpenGLTexture); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_input_set_texture';

// ����JPEG������
//
// @param stream ��Ҫʹ�õ�CUDA����������cudaStreamDefault��0x00��
// @return �ɹ�ʱ���ر������ṹ��ָ�룬���򷵻�NULL
function gpujpeg_encoder_create(stream: cudaStream_t): TGPUJPEGEncoder; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_create';

// ��������ڴ��С���ܹ���������ͼ������������� x �߶ȣ���
//
// @param param ��������ṹ��ָ��
// @param param_image ͼ�����ݲ����ṹ��ָ��
// @param image_input_type ͼ����������ö��ֵ
// @param memory_size �������豸�ڴ���
// @param max_pixels ָ�룬���ڽ��ռ���ó������������
// @return �ɹ�ʱ������ʹ�õ��豸�ڴ��С�����ֽ�Ϊ��λ�������򷵻�0
function gpujpeg_encoder_max_pixels(param: PGPUJPEGParameters;
  param_image: PGPUJPEGImageParameters;
  image_input_type: TGPUJPEGEncoderInputType; memory_size: NativeUInt;
  var max_pixels: Integer): NativeUInt; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_max_pixels';

// �������ڱ���ָ����������ͼ��������豸�ڴ�����С��
//
// @param param ��������ṹ��ָ��
// @param param_image ͼ�����ݲ����ṹ��ָ��
// @param image_input_type ͼ����������ö��ֵ
// @param max_pixels ָ���������������
// @return �ɹ�ʱ�������ֽ�Ϊ��λ�������豸�ڴ��������򷵻�0
function gpujpeg_encoder_max_memory(param: PGPUJPEGParameters;
  param_image: PGPUJPEGImageParameters;
  image_input_type: TGPUJPEGEncoderInputType; max_pixels: Integer): NativeUInt;
  cdecl; external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_max_memory';

// Ԥ��Ϊ����ͼ�����ط������б��뻺������
//
// @param encoder �������ṹ��ָ��
// @param param ��������ṹ��ָ�루������
// @param param_image ͼ�����ݲ����ṹ��ָ�루������
// @param image_input_type ͼ����������ö��ֵ
// @return �ɹ�ʱ����0�����򷵻ط���ֵ
function gpujpeg_encoder_allocate(encoder: TGPUJPEGEncoder;
  param: PGPUJPEGParameters; param_image: PGPUJPEGImageParameters;
  image_input_type: TGPUJPEGEncoderInputType): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_allocate';

// ʹ�ñ�����ѹ��ͼ��
//
// @param encoder �������ṹ��ָ��
// @param param ��������ṹ��ָ��
// @param param_image ͼ�����ݲ����ṹ��ָ��
// @param input Դͼ����������ṹ��ָ��
// @param image_compressed ѹ����ͼ�����ݻ������ı�����ַָ�룬ѹ�����ͼ�����ݽ��������ڴ˴�
// @param image_compressed_size ѹ����ͼ���С�ı�����ַָ�롣�û������ɱ��������������߲�Ӧ�ͷš�
// ����������һ�ε��� gpujpeg_encoder_encode() ֮ǰ��Ч��
// @return �ɹ�ʱ����0�����򷵻ط���ֵ
function gpujpeg_encoder_encode(encoder: TGPUJPEGEncoder;
  param: PGPUJPEGParameters; param_image: PGPUJPEGImageParameters;
  input: PGPUJPEGEncoderInput; var image_compressed: PByte;
  var image_compressed_size: NativeUInt): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_encode';

// �����ϴα���ͼ��ĳ���ʱ��ͳ����Ϣ
// @return �ɹ�ʱ����0�����򷵻ط���ֵ
// @note
// ��Щֵ��Ϊ�ṩ��Ϣ�͵�����;����������Ϊ����API��һ���֡�
function gpujpeg_encoder_get_stats(encoder: TGPUJPEGEncoder;
  stats: PGPUJPEGDurationStats): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_get_stats';

// ǿ�����JPEGͷ��
//
// ͷ������Ӧ�ܹ��������ɵ�JPEGͼ�����������BT.601ȫ��ΧYCbCrͼ��ʹ��JFIF����������㣬�����ɵ�JPEGͼ�����������������ݡ�
procedure gpujpeg_encoder_set_jpeg_header(encoder: TGPUJPEGEncoder;
  header_type: TGPUJPEGHeaderType); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_set_jpeg_header';

// �ṩ���ָ��param_image���������������ü������ƽ��ͼ���С�����ܡ�
// @param subsampling ����ģʽ��������444��422��420
function gpujpeg_encoder_suggest_restart_interval
  (param_image: PGPUJPEGImageParameters; subsampling: Integer;
  interleaved: Boolean; verbose: Boolean): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_suggest_restart_interval';

// ����JPEG������
function gpujpeg_encoder_destroy(encoder: TGPUJPEGEncoder): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_encoder_destroy';

implementation

end.
