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
    fileupload   = document.getElementById('upload-form'),
    csrfToken    = document.querySelector('meta[name="csrf-token"]').content,
    variantId    = fileupload.querySelector('input[name="image[viewable_id]"').value;


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
        details = progressRow.querySelector('details');

    formData.append('image[attachment]', file);
    formData.append('image[viewable_id]', variantId);

    previewFile(file, progressRow);
    details.innerHTML = file.name;
    progressZone.appendChild(progressRow);

    // send the image to the server
    var xhr = new XMLHttpRequest();
    xhr.open('POST', window.location.pathname);
    xhr.setRequestHeader('X-CSRF-Token', csrfToken);
    xhr.onload = function() {
      progressBar.value = progressBar.innerHTML = 100;
    };

    if (tests.progress) {
      xhr.upload.onprogress = function (event) {
        if (event.lengthComputable) {
          var complete = (event.loaded / event.total * 100 | 0);
          progressBar.value = progressBar.innerHTML = complete;
        }
      }
    }

    xhr.send(formData);
  }

  if (tests.dnd) {
    uploadZone.ondragover = function () { this.className = 'hover'; return false; };
    uploadZone.ondragend = function () { this.className = ''; return false; };
    uploadZone.ondrop = function (e) {
      this.className = '';
      e.preventDefault();
      for (var i = 0; i < e.dataTransfer.files.length; i++) {
        upload(e.dataTransfer.files[i]);
      }
    }
  } else {
    fileupload.className = 'hidden';
    fileupload.querySelector('input').onchange = function () {
      for (var i = 0; i < this.files.length; i++) {
        upload(this.files[i]);
      }
    };
  }
};

Spree.ready(function () {
  Spree.prepareImageUploader();
});
