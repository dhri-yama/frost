# Credits

- **Ellipsis** (https://github.com/ronny/ellipsis, Apache-2.0) found that macOS 27's `MenuBarAgent` can hide apps through the
  assessment-mode allow-list in the private `MenuBarClientCore` framework, and documented what that allow-list does and does not
  hide. Frost's `MenuBarRestriction` is written from those findings and the framework's public-looking class and selector names;
  it does not copy Ellipsis's source.
- **Ice** (https://github.com/jordanbaird/Ice) and its forks established the wide-divider technique Frost still uses before macOS 27.
- Gazewell, by the same author as Frost, supplied the theme and settings-component architecture.
