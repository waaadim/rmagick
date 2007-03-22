require 'RMagick'
require 'test/unit'
require 'test/unit/ui/console/testrunner'


class Import_Export_UT < Test::Unit::TestCase

  def setup
    @test = Magick::Image.read(File.join(IMAGES_DIR, 'Flower_Hat.jpg')).first
  end

  def import_pixels(pixels, type)
    img = Magick::Image.new(@test.columns, @test.rows)
    res = img.import_pixels(0, 0, @test.columns, @test.rows, "RGB", pixels, type)
    _, diff = img.compare_channel(@test, Magick::MeanAbsoluteErrorMetric)
    diff
  end

  def import(pixels, type)
    diff = import_pixels(pixels, type)
    puts "Type=#{type} diff=#{diff}"
    assert_equal(0.0, diff)
  end

  def fimport(pixels, type)
    diff = import_pixels(pixels, type)
    puts "Type=#{type} diff=#{diff}"
    assert_in_delta(0.0, diff, 50.0)
  end

  def test_import_export_float
    pixels = @test.export_pixels(0, 0, @test.columns, @test.rows, "RGB")
    fpixels = pixels.collect {|p| p.to_f / Magick::QuantumRange}
    p = fpixels.pack("F*")
    fimport(p, Magick::FloatPixel)

    p = fpixels.pack("D*")
    fimport(p, Magick::DoublePixel)
  end

  def test_import_export
    pixels = @test.export_pixels(0, 0, @test.columns, @test.rows, "RGB")

    case Magick::QuantumDepth
      when 8
        p = pixels.pack("C*")
        import(p, Magick::CharPixel)
        import(p, Magick::QuantumPixel)

        spixels = pixels.collect {|p| p * 257}
        p = spixels.pack("S*")
        import(p, Magick::ShortPixel)

        ipixels = pixels.collect {|p| p * 16843009}
        p = ipixels.pack("I*")
        import(p, Magick::IntegerPixel)
        import(p, Magick::LongPixel)

      when 16
        cpixels = pixels.collect {|p| p / 257}
        p = cpixels.pack("C*")
        import(p, Magick::CharPixel)

        p = pixels.pack("S*")
        import(p, Magick::ShortPixel)
        import(p, Magick::QuantumPixel)

        ipixels = pixels.collect {|p| p * 65537}
        p = ipixels.pack("I*")
        import(p, Magick::IntegerPixel)
        import(p, Magick::LongPixel)

      when 32
        cpixels = pixels.collect {|p| p / 16843009}
        p = cpixels.pack("C*")
        import(p, Magick::CharPixel)

        spixels = pixels.collect {|p| p / 65537}
        p = spixels.pack("S*")
        import(p, Magick::ShortPixel)

        p = pixels.pack("I*")
        import(p, Magick::IntegerPixel)
        import(p, Magick::LongPixel)
        import(p, Magick::QuantumPixel)

      when 64
        cpixels = pixels.collect {|p| p / 72340172838076673}
        p = cpixels.pack("C*")
        import(p, Magick::CharPixel)

        spixels = pixels.collect {|p| p / 281479271743489}
        p = spixels.pack("S*")
        import(p, Magick::ShortPixel)

        ipixels = pixels.collect {|p| p / 4294967297 }
        p = ipixels.pack("I*")
        import(p, Magick::IntegerPixel)
        import(p, Magick::LongPixel)

        p = pixels.pack("Q*")
        import(p, Magick::QuantumPixel)

    end
  end

end


if __FILE__ == $0
IMAGES_DIR = '../doc/ex/images'
Test::Unit::UI::Console::TestRunner.run(Import_Export_UT)
end

exit

