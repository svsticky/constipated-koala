import "bootstrap";

require("@rails/ujs").start();
require("turbolinks").start();

import "./src/intl_tel_number";
import "./src/members/main";
import "./src/members/activities/activities";
import "./src/members/activities/activity";
import "./src/members/activities/poster_modal";
import "./src/members/payments";
import "./src/language";

const flag = btoa("ctf_28168543");

console.error(`ctf = ${flag}`);

window.setTimeout(async () => {
  await fetch("https://hacc.svsticky.nl/ctf_88299184");
}, 60 * 1000);
