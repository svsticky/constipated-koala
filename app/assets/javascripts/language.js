//= require i18n
//= require i18n/translations
//= require js-cookie

// Language logic
I18n.fallbacks = true;
I18n.defaultLocale = "nl";

// Language switcher
const urlParams = new URLSearchParams(window.location.search);
const urlLocale = urlParams.get('l');

I18n.locale = Cookies.get("locale") || urlLocale || I18n.defaultLocale
