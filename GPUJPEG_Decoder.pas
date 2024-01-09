unit GPUJPEG_Decoder;

interface

uses
  GPUJPEG_Type, GPUJPEG_Common;

type
  // �������ṹ�壨δ��������Ա����������

  TGPUJPEGDecoder = Pointer;

  // �������������ö��
  TGPUJPEGDecoderOutputType = (GPUJPEG_DECODER_OUTPUT_INTERNAL_BUFFER,
    // ʹ�ý������ڲ����������
    GPUJPEG_DECODER_OUTPUT_CUSTOM_BUFFER, // ʹ���Զ������������
    GPUJPEG_DECODER_OUTPUT_OPENGL_TEXTURE, // ʹ��OpenGL����PBO��Դ��Ϊ���������
    GPUJPEG_DECODER_OUTPUT_CUDA_BUFFER, // ʹ���ڲ�CUDA��������Ϊ���������
    GPUJPEG_DECODER_OUTPUT_CUSTOM_CUDA_BUFFER // ʹ���Զ���CUDA��������Ϊ���������
    );

  // ����������ṹ��
  PGPUJPEGDecoderOutput = ^TGPUJPEGDecoderOutput;

  TGPUJPEGDecoderOutput = record
    // �������
    Type_: TGPUJPEGDecoderOutputType;

    // ��ѹ���������
    Data: PByte;

    // ��ѹ�������ݴ�С
    DataSize: NativeUInt;

    // ��������ɫ�ռ�
    ColorSpace: TGPUJPEGColorSpace;

    // ���������ظ�ʽ
    PixelFormat: TGPUJPEGPixelFormat;

    // OpenGL����
    Texture: PGPUJPEGOpenGLTexture;
  end;

  // ��Ĭ�ϲ������õ�����������ṹ����
  //
  // @param output ����������ṹ��ָ��
procedure gpujpeg_decoder_output_set_default(output: PGPUJPEGDecoderOutput);
  cdecl; external GPUJPEG_LIBRARY_NAME name
  'gpujpeg_decoder_output_set_default';

// ���������������Ϊ�Զ��建����
//
// @param output        ����������ṹ��ָ��
// @param custom_buffer �Զ��建������ָ��
procedure gpujpeg_decoder_output_set_custom(output: PGPUJPEGDecoderOutput;
  custom_buffer: PByte); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_output_set_custom';

// ���������������ΪOpenGL����
//
// @param output ����������ṹ��ָ��
// @param texture OpenGL����ṹ��ָ��
procedure gpujpeg_decoder_output_set_texture(output: PGPUJPEGDecoderOutput;
  Texture: PGPUJPEGOpenGLTexture); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_output_set_texture';

// ���������ΪCUDA������
//
// @param output ����������ṹ��ָ��
procedure gpujpeg_decoder_output_set_cuda_buffer(output: PGPUJPEGDecoderOutput);
  cdecl; external GPUJPEG_LIBRARY_NAME name
  'gpujpeg_decoder_output_set_cuda_buffer';

// ���������������Ϊ�Զ���CUDA������
//
// @param output          ����������ṹ��ָ��
// @param d_custom_buffer �豸�ڴ��е��Զ��建����ָ��
// @return �޷���ֵ��void��
procedure gpujpeg_decoder_output_set_custom_cuda(output: PGPUJPEGDecoderOutput;
  d_custom_buffer: PByte); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_output_set_custom_cuda';

// ����JPEG������
//
// @param stream ��Ҫʹ�õ�CUDA����������cudaStreamDefault��ֵΪ0x00��
// @return �ɹ�ʱ���ؽ������ṹ��ָ�룬���򷵻�NULL
function gpujpeg_decoder_create(stream: cudaStream_t): TGPUJPEGDecoder; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_create';

// ��ʼ������ض�ͼ�����Ե�JPEG������
//
// ������������صģ�
// - ͼ��ߴ硢�������
// - ��Ҫ�����������ظ�ʽ
// - ����ʽ�����ü����color_space_internal��ͨ��ΪGPUJPEG_YCBCR_BT601_256LVLS��
// - ��ȷ���Ӳ�������
//
// @note
// ����Ҫ�û�������ã���ѹ�������л����ͼ�������Զ���ʼ����������
//
// @param decoder �������ṹ��ָ��
// @param param ��������ṹ��ָ�루��������ָ��Ľṹ��ᱻ����
// @param param_image ͼ�����ݲ����ṹ��ָ�루��������ָ��Ľṹ��ᱻ����
// @return �ɹ�ʱ����0�����򷵻ط���ֵ
function gpujpeg_decoder_init(decoder: TGPUJPEGDecoder;
  param: PGPUJPEGParameters; param_image: PGPUJPEGParameters): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_init';

// ʹ�ý�������ѹ��ͼ��
//
// @param decoder �������ṹ��ָ��
// @param image Դͼ�����ݵ�ָ��
// @param image_size Դͼ�����ݴ�С�����ֽ�Ϊ��λ��
// @param output ��������ṹ��ָ�룬���а�����ָ���ѹ����ͼ�����ݻ�������ָ��ͽ�ѹ��ͼ���С����Ϣ
// @return �ɹ�ʱ����0�����򷵻ط���ֵ
function gpujpeg_decoder_decode(decoder: TGPUJPEGDecoder; image: PByte;
  image_size: NativeUInt; output: PGPUJPEGDecoderOutput): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_decode';

// �����ϴν���ͼ��ĳ���ʱ��ͳ����Ϣ
// @return �ɹ�ʱ����0�����򷵻ط���ֵ
// @note
// ��Щֵ�����ṩ��Ϣ�͵���ʹ�ã���˲�����Ϊ����API��һ���֡�
function gpujpeg_decoder_get_stats(decoder: TGPUJPEGDecoder;
  stats: PGPUJPEGDurationStats): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_get_stats';

// ����JPEG������
//
// @param decoder �������ṹ��ָ��
// @return �ɹ�����ʱ����0�����򷵻ط���ֵ
function gpujpeg_decoder_destroy(decoder: TGPUJPEGDecoder): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_destroy';

// ���������ʽ
//
// @param decoder         �������ṹ��ָ��
// @param color_space     ��������ɫ�ʿռ�ö��ֵ
// @param sampling_factor �������ɫ��������ö��ֵ
procedure gpujpeg_decoder_set_output_format(decoder: TGPUJPEGDecoder;
  color_space: TGPUJPEGColorSpace; sampling_factor: TGPUJPEGPixelFormat); cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_set_output_format';

// �ú�����gpujpeg_reader_get_image_info������ͬ
function gpujpeg_decoder_get_image_info(image: PByte; image_size: NativeUInt;
  param_image: PGPUJPEGImageParameters; param: PGPUJPEGParameters;
  var segment_count: Integer): Integer; cdecl;
  external GPUJPEG_LIBRARY_NAME name 'gpujpeg_decoder_get_image_info';

implementation

end.
