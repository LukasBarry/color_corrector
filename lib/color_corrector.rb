# frozen_string_literal: true

require 'color_corrector/color'
require 'color_corrector/version'

# # Color Corrector
module ColorCorrector
  ONE_SIXTH = 1 / 6.0
  ONE_THIRD = 1 / 3.0
  TWO_THIRDS = 2 / 3.0

  class << self
    def make_readable(background, foreground, level = 'AA', size = 'large')
      until readable?(background, foreground, level, size)
        background = if light?(foreground)
                       darken(background)
                     else
                       lighten(background)
                     end
      end
      background
    end

    def readable?(background, foreground, level = 'AA', size = 'large')
      ratio = contrast_ratio(background, foreground)
      contrast = case [level, size]
                 when %w[AA large]
                   3
                 when %w[AAA small]
                   7
                 else # %w[AA small], %w[AAA large]
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
        chroma = max - min
        saturation =
          lightness > 0.5 ? (chroma / (2 - max - min)) : (chroma / (max + min))
        hue = case max
              when red
                (green - blue) / chroma + (green < blue ? 6 : 0)
              when green
                (blue - red) / chroma + 2
              when blue
                (red - green) / chroma + 4
              end
        hue /= 6
      end
      [hue, saturation, lightness]
    end

    # Variables papa, quebec and tango were originally designated by single
    # letters but have been changed to match the NATO photonetic alphabet
    def hsl_to_rgb(hue, saturation, lightness)
      if saturation.zero?
        red = green = blue = lightness
      else
        quebec = if lightness < 0.5
                   lightness * (1 + saturation)
                 else
                   lightness + saturation - lightness * saturation
                 end
        papa = 2 * lightness - quebec
        red, green, blue = [ONE_THIRD, 0, -ONE_THIRD].map do |offset|
          hue_to_rgb papa, quebec, hue + offset
        end
      end
      [red, green, blue].map { |component| (component * 255).round }
    end

    # :reek:FeatureEnvy
    def hue_to_rgb(papa, quebec, tango)
      tango = bound_hue_01(tango)
      if tango < ONE_SIXTH
        papa + (quebec - papa) * 6 * tango
      elsif tango < 0.5 # (1 / 2.0)
        quebec
      elsif tango < TWO_THIRDS
        papa + (quebec - papa) * (TWO_THIRDS - tango) * 6
      else
        papa
      end
    end

    def bound_hue_01(hue)
      if hue.negative?
        hue + 1
      elsif hue > 1
        hue - 1
      else
        hue
      end
    end

    # :reek:UncommunicativeVariableName and :reek:UncommunicativeParameterName
    def ratio(rgb1, rgb2)
      c1, c2 = [rgb1, rgb2].map { |rgb| Color.new(rgb) }
      l1, l2 = [c1, c2].map(&:relative_luminance).sort
      (l2 + 0.05) / (l1 + 0.05)
    end

    def relative_luminance(red, green, blue)
      (0.2126 * f(red)) + (0.7152 * f(green)) + (0.0722 * f(blue))
    end

    # :reek:UncommunicativeVariableName and :reek:UncommunicativeMethodName
    def f(component)
      c = component / 255.0
      c <= 0.03928 ? c : ((c + 0.055) / 1.055)**2.4
    end

    def light?(hex)
      red, green, blue = hex.delete('#').scan(/../).map(&:hex)
      luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
      luma >= 128
    end

    def dark?(hex)
      red, green, blue = hex.delete('#').scan(/../).map(&:hex)
      luma = 0.2126 * red + 0.7152 * green + 0.0722 * blue
      luma < 128
    end
  end
end
