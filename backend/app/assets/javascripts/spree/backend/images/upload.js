// Inspired by: http://html5demos.com/dnd-upload
Spree.prepareImageUploader = function () {
  var uploadZone = document.getElementById('upload-zone');
  if(!uploadZone) return;

  var tests = {
      filereader: typeof FileReader != 'undefined',
      dnd: 'draggable' in document.createElement('span'),
      formdata: !!window.FormData,
      progress: "upload" in new XMLHttpRequest
    },
    support = {
      filereader: document.getElementById('filereader'),
      formdata: document.getElementById('formdata'),
      progress: document.getElementById('progress')
    },
    acceptedTypes = {
      'image/png': true,
      'image/jpeg': true,
      'image/gif': true
    },
    progressTmpl = document.createElement('div'),
    progressZone = document.getElementById('progress-zone'),
    uploadForm   = document.getElementById('upload-form'),
    csrfToken    = document.querySelector('meta[name="csrf-token"]').content,
    variantId    = uploadForm.querySelector('input[name="image[viewable_id]"').value;


  // Parse the progress template
  progressTmpl.innerHTML = document.getElementById('progress-tmpl').innerHTML;

  "filereader formdata progress".split(' ').forEach(function (api) {
    support[api].className = (tests[api] === false) ? 'red' : 'hidden'
  });

  function previewFile(file, progressRow) {
    if (tests.filereader === true && acceptedTypes[file.type] === true) {
      var reader = new FileReader();
      reader.onload = function (event) {
        var image = progressRow.querySelector('img');
        image.src = event.target.result;
      };

      reader.readAsDataURL(file);
    }  else {
      progressRow.innerHTML += '<p>Uploaded ' + file.name + ' ' + (file.size ? (file.size/1024|0) + 'K' : '');
      console.log(file);
    }
  }

  function upload(file) {
    if (!tests.formdata) return;

    var formData = new FormData(),
        progressRow = progressTmpl.cloneNode(true),
        progressBar = progressRow.querySelector('progress'),
        summary = progressRow.querySelector('summary'),
        uploadedId = Math.round((Math.random()*1000000)).toString();

    formData.append('image[attachment]', file);
    formData.append('image[viewable_id]', variantId);
    formData.append('uploaded_id', uploadedId);

    progressRow.setAttribute('data-uploaded-id', uploadedId)

    previewFile(file, progressRow);
    summary.innerHTML = file.name;
    progressZone.appendChild(progressRow);

    // send the image to the server
    Spree.ajax({
      url: window.location.pathname,
      type: "POST",
      dataType: 'script',
      data: formData,
      processData: false,  // tell jQuery not to process the data
      contentType: false,   // tell jQuery not to set contentType
      xhr: function () {
        xhr = $.ajaxSettings.xhr();
        if (tests.progress) {
          xhr.upload.onprogress = function (event) {
            if (event.lengthComputable) {
              var complete = (event.loaded / event.total * 100 | 0);
              progressBar.value = progressBar.innerHTML = complete;
            }
          };
        }
        return xhr;
      }
    }).done(function() {
      progressBar.value = progressBar.innerHTML = 100;
    }).error(function() {
      progressRow.querySelector('error').classList.remove('hidden') ;
    });
  }

  if (tests.dnd) {
    uploadZone.ondragover = function () { this.className = 'hover'; return false; };
    uploadZone.ondragend = function () { this.className = ''; return false; };
    uploadZone.ondrop = function (e) {
      e.preventDefault();
      for (var i = 0; i < e.dataTransfer.files.length; i++) {
        upload(e.dataTransfer.files[i]);
      }
    }
  }

  uploadForm.querySelector('input[type="file"]').onchange = function () {
    for (var i = 0; i < this.files.length; i++) {
      upload(this.files[i]);
    }
  };
};

Spree.ready(function () {
  Spree.prepareImageUploader();
});
