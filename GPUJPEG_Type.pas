unit GPUJPEG_Type;

interface

// ��������
const
  GPUJPEG_MAX_COMPONENT_COUNT = 4; // �����ɫ������

  // ��־λ����
const
  GPUJPEG_VERBOSE = 1; // ��ʾ��ϸ��Ϣ
  GPUJPEG_OPENGL_INTEROPERABILITY = 2; // ֧��OpenGL��������

  // ����������Ϣͷ����
const
  GPUJPEG_MAX_SEGMENT_INFO_HEADER_COUNT = 100;

  // �������
const
  GPUJPEG_NOERR = 0; // �޴���
  GPUJPEG_ERROR = -1; // ͨ�ô���
  GPUJPEG_ERR_WRONG_SUBSAMPLING = -2; // �Ӳ���ģʽ����
  GPUJPEG_ERR_RESTART_CHANGE = -3; // ���ü�����Ĵ���

  // JPEG�������֧�ֵ���ɫ�ռ�
type
  TGPUJPEGColorSpace = (GPUJPEG_NONE = 0, GPUJPEG_RGB = 1,
    GPUJPEG_YCBCR_BT601 = 2, // ���޷�ΧYCbCr BT.601
    GPUJPEG_YCBCR_BT601_256LVLS = 3, // ȫ��ΧYCbCr BT.601
    GPUJPEG_YCBCR_JPEG = GPUJPEG_YCBCR_BT601_256LVLS, GPUJPEG_YCBCR_BT709 = 4,
    // ���޷�ΧYCbCr BT.709
    GPUJPEG_YCBCR = GPUJPEG_YCBCR_BT709, GPUJPEG_YUV = 5
    // @deprecated �����Ƴ����Ƿ���Ҫ������ͨ������ENABLE_YUV����Ԥ����ͺ���
    );

  // ����/���ͼ�����ݵ����ظ�ʽ
type
  TGPUJPEGPixelFormat = (GPUJPEG_PIXFMT_NONE = -1,

    /// 8bit�޷���������1������
    GPUJPEG_U8 = 0,

    /// 8bit�޷���������3��������4:4:4����������˳��comp#0 comp#1 comp#2������
    GPUJPEG_444_U8_P012 = 1,

    /// 8bit�޷���������3��������4:4:4��ƽ���ʽ
    GPUJPEG_444_U8_P0P1P2 = 2,

    /// 8bit�޷���������3��������4:2:2������˳��comp#1 comp#0 comp#2 comp#0������
    GPUJPEG_422_U8_P1020 = 3,

    /// 8bit�޷���������ƽ���ʽ��3��������4:2:2��ƽ���ʽ
    GPUJPEG_422_U8_P0P1P2 = 4,

    /// 8bit�޷���������ƽ���ʽ��3��������4:2:0��ƽ���ʽ
    GPUJPEG_420_U8_P0P1P2 = 5,

    /// 8bit�޷���������3��������ÿ�����������ֽ������32λ��4:4:4����������
    GPUJPEG_444_U8_P012Z = 6,

    /// 8bit�޷���������3��4��������ÿ�������ÿ�ѡalpha�������4�������������Ϊ0xFF�����32λ��4:4:4(:4)����������
    GPUJPEG_444_U8_P012A = 7,

    GPUJPEG_PIXFMT_NO_ALPHA = GPUJPEG_PIXFMT_NONE - 1,
    // ��ʾ�κβ���alphaͨ�������ظ�ʽռλ��������ö��֮���Ա���-Wswitch����
    GPUJPEG_PIXFMT_PLANAR_STD = GPUJPEG_PIXFMT_NONE - 2
    // ��ʾ��׼ƽ�����ظ�ʽռλ����������444��422��420
    );

  // JPEG��ʽ����ɫ�������Ӳ������ӽṹ��
type
  PGPUJPEGComponentSamplingFactor = ^TGPUJPEGComponentSamplingFactor;

  TGPUJPEGComponentSamplingFactor = record
    horizontal: UInt8;
    vertical: UInt8;
  end;

  // JPEG�������
type
  TGPUJPEGComponentType = (GPUJPEG_COMPONENT_LUMINANCE = 0,
    GPUJPEG_COMPONENT_CHROMINANCE = 1, GPUJPEG_COMPONENT_TYPE_COUNT = 2);

  // JPEG��������������
type
  TGPUJPEGHuffmanType = (GPUJPEG_HUFFMAN_DC = 0, GPUJPEG_HUFFMAN_AC = 1,
    GPUJPEG_HUFFMAN_TYPE_COUNT = 2);

implementation

end.
