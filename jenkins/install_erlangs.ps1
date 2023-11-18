$ERLANG_INSTALL_VERSIONS = @('23.3.4.18','24.3.4.7','25.2')
$ERLANG_INSTALL_PATH = '/Users/big-r/Downloads/' #'C:\\tools\\'

function Download-Erlang {
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$ErlangVersion
    )
    $url = "https://github.com/erlang/otp/releases/download/OTP-${ErlangVersion}/otp_win64_${ErlangVersion}.exe"
    $WebClient = New-Object net.webclient
    $WebClient.Downloadfile($url, "$PSScriptRoot/otp_win64_${ErlangVersion}.exe")
}

function Install-Erlang {
    param (
        [ValidateNotNullOrEmpty()]
        [string[]]$ErlangVersion
    )
    $FilePath = Join-Path -Path $PSScriptRoot -ChildPath "otp_win64_${ErlangVersion}.exe"
    $InstallPath = Join-Path -Path $ERLANG_INSTALL_PATH -ChildPath "erl-${ErlangVersion}"
    $V = New-Object System.Version($ErlangVersion)
    Write-Host $FilePath
    Write-Host $InstallPath
    #Start-Process -Wait -Filepath $FilePath -ArgumentList "/S /D=${ERLANG_INSTALL_PATH}"
}

# https://github.com/erlang/otp/releases/download/OTP-25.2/otp_win64_25.2.exe
# https://github.com/erlang/otp/releases/download/OTP-24.3.4.7/otp_win64_24.3.4.7.exe
# https://github.com/erlang/otp/releases/download/OTP-23.3.4.18/otp_win64_23.3.4.18.exe

foreach ($version in $ERLANG_INSTALL_VERSIONS) {
    Write-Host "$version"
    #Download-Erlang -ErlangVersion $version
    Install-Erlang -ErlangVersion $version
}
