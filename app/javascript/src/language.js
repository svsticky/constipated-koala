import I18n from "./translations";
import Cookies from "js-cookie";

// Language logic
I18n.fallbacks = true;
I18n.defaultLocale = "nl";

// Language switcher
const urlParams = new URLSearchParams(window.location.search);
const urlLocale = urlParams.get("l");

I18n.locale = urlLocale || Cookies.get("locale") || I18n.defaultLocale;

export default I18n;
