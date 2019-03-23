# AutoTagging

This extension adds tags to all resources in any given resourcegroup.

Usually this task is ran at the end of the deployment of all your resources.

[![screenshot-1](screenshots/screenshots-vsts-auto-tagging-1.png "Screenshot-1")](screenshots/screenshots-vsts-auto-tagging-1.png)
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fprombouts%2Fvsts-auto-tagging.svg?type=shield)](https://app.fossa.io/projects/git%2Bgithub.com%2Fprombouts%2Fvsts-auto-tagging?ref=badge_shield)

## Notes

The maximum number of tags on a resource is 15. The extension only checks initially if you do not exceed that value in the multiline box. This extension does not delete existing tags, so there is a possibility the script will fail. In that case the output window will show this in the form of an error and will continue to the next resource.

For storage accounts, the tag name is limited to 128 characters, and the tag value is limited to 256 characters. Therefore all tag name and value lengths are limited to those values.

## Help & Contact

See my blog for more info: https://www.peterrombouts.nl/index.php/2018/07/17/vsts-extension-tagging-all-resources-within-a-resource-group

## License
[![FOSSA Status](https://app.fossa.io/api/projects/git%2Bgithub.com%2Fprombouts%2Fvsts-auto-tagging.svg?type=large)](https://app.fossa.io/projects/git%2Bgithub.com%2Fprombouts%2Fvsts-auto-tagging?ref=badge_large)