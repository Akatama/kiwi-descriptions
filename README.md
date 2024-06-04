# openSUSE KIWI Descriptions

This project is used to manage the openSUSE KIWI image descriptions used in composing openSUSE release images.

The `factory` branch is used for openSUSE Tumbleweed images and each `lpXXX` branch is used by each particular openSUSE Leap release.

All changes should be made via the PR workflow.

## Image variants

| Name                           | Image type | Image profiles                   |
|--------------------------------|------------|----------------------------------|
| Base Cloud Edition for clouds  | `oem`      | `Cloud-Base-Generic`             |
|                                |            | `Cloud-Base-AmazonEC2`           |
|                                |            | `Cloud-Base-Azure`               |
|                                |            | `Cloud-Base-GCE`                 |

## Image build quickstart

Set up your development environment and run the image build (substitute `<image_type>` and `<image_profile>` for the appropriate settings):

```bash
# Install kiwi
[]$ sudo zypper install python3-kiwi distribution-gpg-keys
# Run the image build
[]$ sudo ./kiwi-build --image-type=<image_type> --image-profile=<image_profile> --output-dir ./outdir
```

## Image Source Setup for Open Build Service

For submission of the image description into the Open Build Service some adaptions
to the image description such as the repo setup are needed. Therefore the kiwi-build
script provides the --obs-source command which produces the image description sources
in an Open Build Service consumable way.

```bash
[]$ ./kiwi-build --obs-source --image-type=<image_type> --image-profile=<image_profile> --output-dir=obs
```

## Image Upload Setup for the Cloud Edition

Uploading into the cloud can be done using the mash workflow as follows

```bash
[]$ cd ./publish
[]$ podman pull registry.opensuse.org/virtualization/appliances/images/images_tw/opensuse/mash:latest
[]$ podman run --cap-add CAP_SYS_ADMIN --rm -ti --name mash --volume ./mash:/mnt mash
```

Once the mash instance has started, login, setup credentials and run a
workflow. The mash system supports different cloud providers and is based
on a pipeline of services to fetch, test, upload and publish OS images
in the public cloud. All this information is provided by a mash job
description. All job descriptions to publish images to the cloud in the
scope of this project are shared with the mash container instance and
can be found in the `publish/mash` directory.

Perform the following steps to upload the Cloud-Base-AmazonEC2 image
from the associated Open Build Service project at
https://build.opensuse.org/package/show/Cloud:Images:Factory/team_cloud
into the AWS cloud.

1. Login to the instance

        []$ login: masher
        []$ password: linux

2. Create a user for mash:

        []$ mash user create --email cloud-team@opensuse.org

3. Login to mash:

        []$ mash auth login --email cloud-team@opensuse.org

4. Setup public cloud account

        []$ mash account ec2 add \
             --name aws \
             --partition aws \
             --region eu-central-1 \
             --subnet ... \
             --group ... \
             --access-key-id ... \
             --secret-access-key ...

    The values written as ```...``` are sensitive information
    from the respective AWS account credentials and account
    setup.

5. Create a job

        []$ mash job ec2 add /mnt/ec2_x86_64.job

    List your job(s) with the following command:

        []$ mash job list

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
