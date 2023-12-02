---
permalink: /roadmap/
layout: article
title: Roadmap
---

### In Progress

### Planned
- [ ] Quieten specific words
- [ ] Font adjustments
- [ ] Custom trigger words.
	- This is harder than I thought, since triggers are contextual, and simple word searches are not enough.
- [ ] Check color accessibility for viewed-grey-color.
- [ ] **Blocked** Use upstream as canonical page if it ever becomes stable and fast
	- [ ] **Stable**: Old links stop working on upstream. We break them intentionally, since this is a "daily news"  site, but upstream ought not to break. See [this link](https://app.beatrootnews.com/#article-5773) for eg.
	- [ ] **Fast**: Current upstream is too slow. See [this report](https://pagespeed.web.dev/analysis/https-app-beatrootnews-com/scbmz1pf5r?form_factor=mobile).

### Completed
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

See [/about](/about) as well, or [contact Nemo](https://captnemo.in/contact/) for any suggestions.