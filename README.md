# The RSpec Selfie Formatter

An RSpec Formatter for the new generation of programmers.

![Selfie Formatter Animation](example.gif)

The Selfie Formatter takes photos of you while your tests run and uses them to track
progress and format the results.

Currently only works on OS X with iTerm2 >= 3.0. **Warning** see [known issues](#known-issues).

## Installation

ImageMagick is required

```
brew install imagemagick --with-fontconfig
```

Then

```
gem install selfie_formatter
```

Or, in your `Gemfile`

```ruby
gem "selfie_formatter", :group => "test"
```

## Usage

```
rspec -f SelfieFormatter
```

## Known Issues

1. Slower tests. Yes, vanity has its price: the camera takes time to warm up, and a small sleep time is added prior to taking the each photo. At some point the sleep time
may be added as an option.

1. Photos are taken via [imagesnap](https://github.com/rharder/imagesnap), which is a fine program but can quickly eat up memory.
Upwards of 500 MB after 10 or 15 seconds.

1. Photos are taken every 300ms. Unused photos are cleaned up after every test completes but if a single test takes a while to
complete photos can start to eat up disk space.

1. Spec numbers are added to the top left of each image. They will not show up if the background is dark.

At some point I may write something that does not [fake the `Camera` interface via `fork`](https://github.com/sshaw/selfie_formatter/blob/34f1999391695ce7633d79638a0903e1eb612e9e/lib/selfie/camera.rb). [imagesnap](https://github.com/rharder/imagesnap) and [CaptureCamera](https://github.com/fernyb/CaptureCamera) are good starting points.

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).
