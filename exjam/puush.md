---
layout: page
title: Image Stream
permalink: /stream/
---

{% puush_gallery /puush %}

<script>
   $('#puush_gallery').justifiedGallery({
      sizeRangeSuffixes: {
         'lt100':'', 
         'lt240':'', 
         'lt320':'_320', 
         'lt500':'', 
         'lt640':'', 
         'lt1024':''
      },
      rel: 'gallery1',
      margins: 1,
      rowHeight: 150,
      waitThumbnailsLoad: false,
      lastRow: 'justify'
   });

   $('#puush_gallery').find('a').fancybox({
      helpers : {
         title: {
            type: 'inside',
            position: 'top'
         }
      },
      padding: 5,
      margin: 10,
      closeBtn: false
   });
</script>
