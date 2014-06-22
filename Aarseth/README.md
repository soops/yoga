Aarseth: Blogging Template
=============
Forked a minimalistic blogging template made for WordPress. The original developer/product designer is <b><a href="https://github.com/biznickman">Nick O'Neill</a></b>. Inspiration came from <b><a href="http://samsoff.es">Sam Soffes</a></b> and <b><a href="http://www.dustincurtis.com/">Dustin Curtis</a></b>. My version of the template will be called <b>Aarseth</b>. Look at my plans for <b><i>Aarseth</i></b> below.
<br />

Installing Aarseth
=============
If you would like to Install Aarseth and use the template for your companies <i>Press Blog</i> or <i>Personal Blog</i>, you can! Aarseth is very easy to install and use in your website. <b>Please follow the steps for your CMS</b>.<br /><h4>Installing On WordPress</h4>
Just a quick note, before we begin. Aarseth supports WordPress 3.8 and Above. If you run a version of WordPress any lower than that you will need to update to the latest version. The first step is downloading the content. 

```bash
$ cd ~/Desktop/ #cd to where you want to save Aarseth.
$ git clone https://github.com/istx25/Aarseth-template.git #clone the repo
$ cd Aarseth-template #cd into the repo
```

I am not going to explain how to delete the unnecessary files through terminal, so for the people who already know how can delete all the files in <b>/Extras/</b> folder. If you do not know how to remove files through the terminal; just remove them through Finder. The next thing we will do is install the template. We can install it through SSH or FTP.

```bash
$ # I will show you how to install it through SSH first.
$ ssh user@123.456.789 #ssh into your server
$ cd /wp-content/themes/
$ #upload the template to the themes directory
$ exit
```

Or through <b>FTP</b>! Login to your server with your favourite FTP Client and navigate to <b>/wp-content/themes/</b> and pull the file into that folder. Once the <i>template</i> is installed on your WordPress partition, you will need to login to your website and do the following steps:

```bash
Login to your website at http://www.example.com/wp-admin and click "Appearance" and
then "Themes" in the submenu. You will be presented with the list of themes installed
on your copy of WordPress. Click the button "Activate" on the pallet that
says Aarseth-Template.
```

And there you have it! You will have Aarseth working on your WordPress 3.8 or newer partition. Now lets talk about how to install Aarseth on Anchor.

<h4>Installing On Anchor CMS</h4>
If you're wanting to install Aarseth on the Anchor CMS platform, please glance at the instructions to install the template on WordPress because the process is <b>very similiar</b>. You will need to download the template using the steps above. Next you will:

```bash
1. Delete the folder, "Aarseth" and file "index.html".
2. Copy the contents of the /Extras/ folder in Aarseth-template & surface 
   the files to the main directory.
3. Rename the main folder "Aarseth-template" to "default".
```

After the folder has been refactored and ready for upload you will need to either SSH or FTP into your server. Follow the simple instructions below:

```bash
$ ssh user@123.456.789 #ssh into your server
$ cd /themes/
$ #upload the template to the themes directory
$ exit
```
If you are using FTP you will need to upload the directory <b>default</b> into the /themes/ directory of Anchor. Now! Navigate to your webpage <a href="#">http://www.example.com/</a> and Aarseth should be displayed. Thanks for testing out our template. :)<br />

<b><a href="#">COMMON PROBLEMS:</a></b> If Aarseth is not displaying, you will need to refresh your cache, if this does not fix the problem; or you receive PHP errors, please @mention me on twitter at <a href="twitter.com/istx25">@istx25</a> and I can help.



<h1>Roadmap</h1>
I have a few plans for Aarseth that will be implemented in the future. I will be refractoring the PHP code and organize it. I'm quite a perfectionist so I need the code/designs I work on to be <b>very organized</b>. I will also be taking the design of Aarseth into Illustrator and revamping it with new colours, and fonts. I also plan on developing <b>a version of Aarseth that supports the <a href="http://anchorcms.com">Anchor CMS</a></b> as well!

<h3>Changelog</h3>
```
Version 1.0.0
This is the initial version of Aarseth! All the code and designs are from the original dev.

Version 1.0.1
- Changed File Structure from HollerPress to Aarseth.
- Began to Clean & Refactor PHP.

Version 1.0.2
- Added a New Temporary Screenshot.png Graphic.
- Pushing Update 1.2.6 for Pubnub. [Patching the Heartbleed Bug]
- Revoked Certificate in Version 1.0.1 and Signed a new Certificate for 1.0.2!

Version 1.0.2.(1)
- Added Comments in Aarseth/[filename].php files.
- Refactored header.php
- Refactored index.php
- Decreased Template Master Size (Originally: 300kb, Currently: 246kb)

Version 1.1
- Major Update that has fixes stability problems in the template core. [PHP Files]
- We have started the journey for Aarseth to support the Anchor CMS.

Version 1.1.2
- Minor Refactoring in Aarseth for Anchor.
- Added New Graphics to Anchor's side.

Version 1.1.3
- Syntax-anchor[.html] has been deprecated. Now unified with WordPress version.
- Minor UI Adjustments
```
License
=============
 <b>Copyright (c) 2014 Apollo Computational Research Group</b><br />
 Commits made by Douglas Bumby. Twitter: <a href="http://www.twitter.com/istx25">@istx25</a>

 <b>THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.</b><br />
