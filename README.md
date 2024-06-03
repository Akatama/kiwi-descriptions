# openSUSE KIWI Descriptions

This project is used to manage the openSUSE KIWI image descriptions used in composing openSUSE release images.

The `factory` branch is used for openSUSE Tumbleweed images and each `lpXXX` branch is used by each particular openSUSE Leap release.

All changes should be made via the PR workflow.

## Image variants

Please look at [`VARIANTS`](VARIANTS.md) for details on the available
configurations that can be built.

## Image build quickstart

Set up your development environment and run the image build (substitute `<image_type>` and `<image_profile>` for the appropriate settings):

```bash
# Install kiwi
[]$ sudo zypper install python3-kiwi distribution-gpg-keys
# Run the image build
[]$ sudo ./kiwi-build --image-type=<image_type> --image-profile=<image_profile> --output-dir ./outdir
```

## Licensing

This is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, under version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <http://www.gnu.org/licenses/>.
