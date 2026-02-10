{
  time.timeZone = "America/Fortaleza";
  i18n.defaultLocale = "pt_BR.UTF-8";

  console.keyMap = "br-abnt2";

  services.xserver.enable = true;
  services.xserver.xkb = {
    layout = "br";
    model = "abnt2";
    variant = "abnt2";
  };
}
