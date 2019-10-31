# Color Corrector

This project helps you to remain in compliance with [WCAG color contrast guidelines](https://www.w3.org/TR/UNDERSTANDING-WCAG20/visual-audio-contrast-contrast.html). It will help you decide if the color scheme you are using is in compliance, can provide the current ratio between your colors, and also provides the ability to lighten or darken colors as needed.

Also allows for conversion of Hexadecimal to RGB, RGB to HSL, HSL to RGB, and RGB to Hexadecimal


### Getting Started

Add the following to your Gemfile:
```
gem 'color_corrector'
```
and then execute:
```
$ bundle install
```
Or install it yourself as:
```
$ gem install color_corrector
```

### Usage
```ruby
# First color provided is always the background, second color is the foreground

# Make contrast readable when both colors are red:
ColorCorrector.make_readable('#ff0000', '#ff8080')
# => "#af0000"
# Provides new background color
# Available options:
# level - ['A', 'AA', 'AAA']
# size - ['small', 'large']

# Checks whether a background and foreground color are WCAG compliant:
ColorCorrector.readable?('#ff0000', '#ff8080')
# => false
# Available options:
# level - ['A', 'AA', 'AAA']
# size - ['small', 'large']

# Checks the current contrast ration between two colors:
ColorCorrector.contrast_ratio('#ff0000', '#ff8080')
# => 1.6472526953148678
# To be WCAG compliant, need a contrast ratio of 4.5 normally

# Darken any color given:
ColorCorrector.darken('#ff8080')
# => "#ff7b7b"
# Available options:
# amount - 0.01 default
# The higher the amount, the more it darkens it

# Lighten any color given:
ColorCorrector.lighten('#ff0000')
# => "#ff0505"
# Available options:
# amount - 0.01 default
# The higher the amount, the more it lightens it

# Check whether a color would be considered a light color:
ColorCorrector.light?('#ff0000')
# => false

# Check whether a color would be considered a dark color:
ColorCorrector.dark?('#ff0000')
# => true
```
