//= require i18n
//= require i18n/translations
//= require js-cookie

// Language logic
I18n.fallbacks = true;
I18n.defaultLocale = "nl";

// Language switcher
var urlParams = new URLSearchParams(window.location.search);
var urlLocale = urlParams.get("l");

I18n.locale = Cookies.get("locale") || urlLocale || I18n.defaultLocale;
