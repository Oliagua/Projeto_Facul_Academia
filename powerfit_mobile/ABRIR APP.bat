@echo off
chcp 65001 >nul
title PowerFit - aplicativo
cd /d "%~dp0"
rem Garante que o Flutter e o Git sejam encontrados mesmo sem reiniciar o Windows.
set "PATH=%USERPROFILE%\flutter\bin;%USERPROFILE%\mingit\cmd;%PATH%"
echo.
echo  Abrindo o app PowerFit no Chrome...
echo  A primeira vez demora cerca de 1 minuto. Nao feche esta janela.
echo.
echo  Atalhos (com esta janela selecionada):
echo    r = recarregar depois de mudar o codigo
echo    q = fechar o app
echo.
call flutter run -d chrome
echo.
pause
