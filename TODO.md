---
permalink: /roadmap/
layout: article
title: Roadmap
---

### In Progress
- [ ] Drop empty sections in homepage
- [x] Create a /settings page
	- [ ] Show syndicated articles in home page (default OFF)
	- [ ] Pick sections for home-page
	- [ ] Font adjustments
### Planned

- [ ] Check color accessibility for viewed-grey-color.
- [ ] **Blocked** Use upstream as canonical page if it ever becomes stable and fast
	- [ ] **Stable**: Old links stop working on upstream. We break them intentionally, since this is a "daily news"  site, but upstream ought not to break. See [this link](https://app.beatrootnews.com/#article-5773) for eg.
	- [ ] **Fast**: Current upstream is too slow. See [this report](https://pagespeed.web.dev/analysis/https-app-beatrootnews-com/scbmz1pf5r?form_factor=mobile).

### Completed
- [x] Fix top margin/whitespace in topic pages
- [x] Grey out read articles. Keep track using localstorage.
- [x] Un-grey articles that were updated. Use combination of article_id + last_updated
- [x] Redirect 404 articles to app.beatrootnews. **Note**: Upstream links are also broken currently, so we need something better.
- [x] Add sign for "developing story"
- [x] Fix tap target size in bottom footer.
- [x] Make "/" in bottom footer using CSS after
- [x] Highlight words
- [x] Clear "read articles"

See [/about](/about) as well, or [contact Nemo](https://captnemo.in/contact/) for any suggestions.