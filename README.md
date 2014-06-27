VEVideoEditor
=============

Video Editor for iOS based from AV Foundation Framework.

Features
  * Add image layer to video
  * Merge multiple video
  * Change audio to video

----------------------------------------------------------

Installation.

1. Add All of Files in "VideoEditor/model" to your project.
2. Add Above framework to your project.
  * AVFoundation.framework
  * CoreMedia.framework
  * CoreVideo.framework
  * MobileCoreServices.framework
  * MediaPlayer.framework

----------------------------------------------------------

How to use

```
#include "VE.h"

//init VEVideoEditor with video file
VEVideoEditor *videoEditor = [[VEVideoEditor alloc] initWithURL:url];

//set preview view
[self.view addSubview:videoEditor.previewViewController.view];

//Add image to video
UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
VEVideoComponent *component = [[VEVideoComponent alloc] initWithView:imageView];

component.presentTime = 0.f;
component.duration = videoEditor.duration;

[videoEditor.videoComposition addComponent:component];

//Export video
[videoEditor exportToURL:url];
```

----------------------------------------------------------

if you still have any question, feel free to contact me: sunama.sukrit@gmail.com
