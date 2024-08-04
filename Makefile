.PHONY: dependencies run

dependencies: install_imagemagick go_deps

# Install ImageMagick via Homebrew
.PHONY: install_imagemagick
install_imagemagick:
	brew install imagemagick pkg-config exiftool
	pkg-config --cflags --libs MagickWand

# Get necessary Go packages
.PHONY: go_get_packages
go_deps:
	go mod tidy


# Serve the Hugo site locally
.PHONY: serve
serve:
	hugo server --disableFastRender

# Manually set cleaned flags
# Adjust the include path according to your ImageMagick installation
INCLUDE_PATH := /opt/homebrew/Cellar/imagemagick//7.1.1-36/include/ImageMagick-7/MagickWand/
LIBRARY_PATH := /opt/homebrew/Cellar/imagemagick/7.1.1-36/lib

CGO_CFLAGS := -I$(INCLUDE_PATH)
CGO_LDFLAGS := -L$(LIBRARY_PATH) -lMagickWand-7.Q16HDRI -lMagickCore-7.Q16HDRI

# Clean problematic flags from pkg-config output
# clean_cflags = $(shell pkg-config --cflags MagickWand | sed 's/-Xpreprocessor//g' | sed 's/-fopenmp//g')
# clean_ldflags = $(shell pkg-config --libs MagickWand)

# Run the Go script. Careful when changing or removing this target, as it is used by a git pre-commit hook.
.PHONY: compress-photos
compress-photos:
	CGO_CFLAGS_ALLOW='-Xpreprocessor' CGO_CFLAGS="$(CGO_CFLAGS)" CGO_LDFLAGS="$(CGO_LDFLAGS)" go run scripts/photo-processor.go ./content/
