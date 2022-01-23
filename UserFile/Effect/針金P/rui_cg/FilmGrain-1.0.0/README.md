FilmGrain
========
　　FilmGrain is an image effect for MikuMikuDance, the method is using 3D noise texture, this is a vert fast technique to achieve film grain and vignette, dark border, chromatic aberration, etc, it can help to add more realistic and also produces better effect

[![link text](./Screenshots/preview.png)](https://raw.githubusercontent.com/MikuMikuShaders/FilmGrain/master/Screenshots/preview.png)

Requirements:
-----------
* MikuMikuDance (Only tested on 926 version x64)
* MikuMikuEffect (Only tested on 037 version x64)
* Direct3D 9 With Shader Model 3.0 (ps_3_0)

Quickstart:
-----------
* Download a zip archive from the github page.
* Un-zip the archive.
* Put the the `FilmGrain.x` to the MMD window
* Put the the `FilmGrainController.pmx` to the MMD window
* Drag the `FilmGrain` to 0.3

Effect Params:
-----------
* `FilmGrain` - Controls how much intensity that add noise on the screen.
* `FilmLineX` - Add scan line on the X-axis of the screen
* `FilmLineX` - Add scan line on the Y-axis of the screen
* `FilmBordersX` - Add dark border around X-axis of the screen
* `FilmBordersY` - Add dark border around Y-axis of the screen
* `Vignette` - Add dark border around the screen corners
* `Dispersion` - Controls how much shifting occurs that simulates the color shifts on the screen
* `DispersionRadius` - Controls how much radius that does not produce this effect in the screen center
* `FilmLoopX` - Controls how much loop number that tile the texture of the whole screen
* `FilmLoopX` - Controls how much loop number that tile the texture of the whole screen on the X-axis
* `FilmLoopY` - Controls how much loop number that tile the texture of the whole screen on the Y-axis

Contact:
------------
　　If you are a developer using this as part of your love and considering contacting me, you can submit code by `Pull requests` or Feel free to contact me via `twitter` and `issues`, i'll add your profile to team members.

* Reach me via Twitter: [@Rui](https://twitter.com/Rui_cg).

[License (MIT)](https://raw.githubusercontent.com/MikuMikuShaders/FilmGrain/master/LICENSE.txt)
-------------------------------------------------------------------------------
	Copyright (C) 2016-2017 Rui. All rights reserved.

	https://github.com/MikuMikuShaders

	Permission is hereby granted, free of charge, to any person obtaining a
	copy of this software and associated documentation files (the "Software"),
	to deal in the Software without restriction, including without limitation
	the rights to use, copy, modify, merge, publish, distribute, sublicense,
	and/or sell copies of the Software, and to permit persons to whom the
	Software is furnished to do so, subject to the following conditions:

	The above copyright notice and this permission notice shall be included
	in all copies or substantial portions of the Software.

	THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
	OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
	FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL
	BRIAN PAUL BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN
	AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN
	CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
