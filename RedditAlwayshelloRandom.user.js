// ==UserScript==
// @name         Reddit Alwayshello Random
// @namespace    http://tampermonkey.net/
// @version      0.7
// @description  Leverages the alwayshello API used by redditrand.com to redirect to a random subreddit.
// @author       CheatFreak & PXA
// @match        *://*.reddit.com/*
// @grant        GM.xmlHttpRequest
// @run-at       document-start
// @connect      api.alwayshello.com
// ==/UserScript==

(function() {
  'use strict';

  function goRandom(nsfw) {
    GM.xmlHttpRequest({
      method: 'GET',
      url: `https://api.alwayshello.com/reddit-runner/rand?nsfw=${nsfw}`,
      onload: response => {
        const result = JSON.parse(response.responseText);
        window.location.href = `${window.location.origin}${result.url}`;
      }
    });
  }

  function replaceLinks() {
    const links = document.querySelectorAll('a');
    links.forEach(link => {
      if (link.href.includes('/r/random')) {
        link.href = 'javascript:void(0)';
        link.addEventListener('click', () => goRandom(0));
      } else if (link.href.includes('/r/randnsfw')) {
        link.href = 'javascript:void(0)';
        link.addEventListener('click', () => goRandom(1));
      }
    });
  }

  document.addEventListener('DOMContentLoaded', replaceLinks);

  if (window.location.pathname.startsWith('/r/random')) {
    goRandom(0);
  } else if (window.location.pathname.startsWith('/r/randnsfw')) {
    goRandom(1);
  }
})();
