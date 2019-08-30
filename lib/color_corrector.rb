# frozen_string_literal: true

require 'color_corrector/color'
require 'color_corrector/version'

# # Color Corrector
module ColorCorrecter
  class << self
    def make_readable(background, foreground, level = 'AA', size = 'large')
      until readable?(background, foreground, level, size)
        background = darken(background)
      end
      background
    end

    def readable?(background, foreground, level = 'AA', size = 'large')
      ratio = contrast_ratio(background, foreground)
      contrast = case [level, size]
                 when %w[AA small], %w[AAA large]
                   4.5
                 when %w[AA large]
                   3
                 when %w[AAA small]
                   7
                 else
                   4.5
                 end
      ratio >= contrast
    end

    def contrast_ratio(background, foreground)
      background = background.delete('#')
      foreground = foreground.delete('#')
      ratio(background, foreground)
    end

    def darken(hex_color, amount = 0.01)
      red, green, blue = hex_color.delete('#').scan(/../).map(&:hex)
      hue, saturation, lightness = rgb_to_hsl(red, blue, green)
      lightness -= amount
      rgb = hsl_to_rgb(hue, saturation, lightness)
      format '#%02x%02x%02x', *rgb
    end

    def lighten(hex_color, amount = 0.01)
      red, green, blue = hex_color.delete('#').scan(/../).map(&:hex)
      hue, saturation, lightness = rgb_to_hsl(red, blue, green)
      lightness += amount
      rgb = hsl_to_rgb(hue, saturation, lightness)
      format '#%02x%02x%02x', *rgb
    end

    def rgb_to_hsl(red, blue, green)
      components = [red, blue, green].map { |chroma| chroma / 255.0 }
      max = components.max
      min = components.min
      red, blue, green = components
      lightness = (max + min) / 2

      if max == min
        hue = saturation = 0
      else
        dark = max - min
        saturation =
          lightness > 0.5 ? (dark / (2 - max - min)) : (dark / (max + min))
        hue = case max
              when red
                (green - blue) / dark + (green < blue ? 6 : 0)
              when green
                (blue - red) / dark + 2
              when blue
                (red - green) / dark + 4
              end
        hue /= 6
      end
      [hue, saturation, lightness]
    end

    def hsl_to_rgb(hue, saturation, lightness)
      if saturation.zero?
        red = green = blue = lightness
      else
        quality = if lightness < 0.5
                    lightness * (1 + saturation)
                  else
                    lightness + saturation - lightness * saturation
                  end
        pure = 2 * lightness - quality
        red = hue_to_rgb(pure, quality, hue + (1 / 3.0))
        green = hue_to_rgb(pure, quality, hue)
        blue = hue_to_rgb(pure, quality, hue - (1 / 3.0))
      end
      [red * 255, green * 255, blue * 255].map(&:round)
    end

    def hue_to_rgb(pure, quality, top)
      top += 1 if top.negative?
      top -= 1 if top > 1
      if top < (1 / 6.0)
        pure + (quality - pure) * 6 * top
      elsif top < (1 / 2.0)
        quality
      elsif top < (2 / 3.0)
        pure + (quality - pure) * ((2 / 3.0) - top) * 6
      else
        pure
      end
    end

    def ratio(rgb1, rgb2)
      c1, c2 = [rgb1, rgb2].map { |rgb| Color.new(rgb) }
      l1, l2 = [c1, c2].map(&:relative_luminance).sort
      (l2 + 0.05) / (l1 + 0.05)
    end

    # :reek:UncommunicativeParameterName
    def relative_luminance(r, g, b)
      (0.2126 * f(r)) + (0.7152 * f(g)) + (0.0722 * f(b))
    end

    # :reek:UncommunicativeVariableName
    def f(component)
      c = component / 255.0
      c <= 0.03928 ? c : ((c + 0.055) / 1.055)**2.4
    end
  end
end
