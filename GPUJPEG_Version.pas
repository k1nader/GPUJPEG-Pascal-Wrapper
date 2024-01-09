unit GPUJPEG_Version;

interface

// 定义GPUJPEG版本号
const
  GPUJPEG_VERSION_MAJOR = 0; // 主版本号
  GPUJPEG_VERSION_MINOR = 21; // 次版本号
  GPUJPEG_VERSION_PATCH = 0; // 补丁版本号

function GPUJPEG_MK_VERSION_INT(major, minor, patch: Integer): Cardinal;
function GPUJPEG_VERSION_INT: Cardinal;

implementation

function GPUJPEG_MK_VERSION_INT(major, minor, patch: Integer): Cardinal;
begin
  Result := Cardinal((major shl 16) or (minor shl 8) or patch);
end;

function GPUJPEG_VERSION_INT: Cardinal;
begin
  Result := GPUJPEG_MK_VERSION_INT(GPUJPEG_VERSION_MAJOR, GPUJPEG_VERSION_MINOR,
    GPUJPEG_VERSION_PATCH);
end;

function LIBGPUJPEG_API_VERSION: Cardinal;
begin
  Result := Cardinal(GPUJPEG_VERSION_MAJOR shl 16) or (GPUJPEG_VERSION_MINOR);
end;

end.
