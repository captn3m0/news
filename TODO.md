---
permalink: /roadmap/
layout: article
title: Roadmap
---

### In Progress

### Planned
- [ ] Improve keyboard navigation using <kbd>J</kbd>/<kbd>K</kbd>.
- [ ] Quieten specific words
	- Instead of "muting" words, where you don't see the news items, we instead want to quieten "words" so that
	  you can skim them faster, and still read it if it feels relevant.
- [ ] Font adjustments
- [ ] Check color accessibility for viewed-grey-color.
- [ ] **Blocked** Use upstream as canonical page if it ever becomes stable and fast
	- [ ] **Stable**: Old links stop working on upstream. We break them intentionally, since this is a "daily news"  site, but upstream ought not to break. See [this link](https://app.beatrootnews.com/#article-5773) for eg.
	- [ ] **Fast**: Current upstream is too slow. See [this report](https://pagespeed.web.dev/analysis/https-app-beatrootnews-com/scbmz1pf5r?form_factor=mobile).
- [ ] Improved onboarding that sets up the user's preferences, and mentions other features.
- [ ] Quick "highlight" feature to easily add words to your highlights.

### Completed
- [x] Add relevant emojis alongside the date for special days.
- [x] Mark articles from yesterday/today using a light/dark border on the right margin
- [x] Mark syndicated articles using the left margin
- [x] Link to Google News for further research
- [x] Provide a share link
- [x] Added podcast player
- [x] Hide chosen topics for home-page
- [x] Grey out read articles. Keep track using localstorage.
- [x] Un-grey articles that were updated. Use combination of article_id + last_updated
- [x] Redirect 404 articles to app.beatrootnews. **Note**: Upstream links are also broken currently, so we need something better.
- [x] Add sign for "developing story"
- [x] Fix tap target size in bottom footer.
- [x] Highlight words
- [x] Clear "read articles"
- [x] Create a /settings page
- [x] Show all articles, and mark syndicated ones better
- [x] Use better list icons

### Wontfix

Decided against adding these features, for now.

- [ ] Custom trigger words.
	- This is harder than I thought, since triggers are contextual, and simple word searches are not enough.

See [/about](/about) as well, or [contact Nemo](https://captnemo.in/contact/) for any suggestions.