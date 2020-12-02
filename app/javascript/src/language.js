import I18n from "i18n-js"
import Cookies from "js-cookie"

// Language logic
I18n.fallbacks = true;
I18n.defaultLocale = "nl";

// Language switcher
var urlParams = new URLSearchParams(window.location.search);
var urlLocale = urlParams.get("l");

I18n.locale = Cookies.get("locale") || urlLocale || I18n.defaultLocale;
