// We import the CSS which is extracted to its own file by esbuild.
// Remove this line if you add a your own CSS build pipeline (e.g postcss).
import "../css/app.css"

// If you want to use Phoenix channels, run `mix help phx.gen.channel`
// to get started and then uncomment the line below.
// import "./user_socket.js"

// You can include dependencies in two ways.
//
// The simplest option is to put them in assets/vendor and
// import them using relative paths:
//
//     import "../vendor/some-package.js"
//
// Alternatively, you can `npm install some-package --prefix assets` and import
// them using a path starting with the package name:
//
//     import "some-package"
//

// Include phoenix_html to handle method=PUT/DELETE in forms and buttons.
import "phoenix_html"
// Establish Phoenix Socket and LiveView configuration.
import {Socket} from "phoenix"
import {LiveSocket} from "phoenix_live_view"
import topbar from "../vendor/topbar"


let csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content")
let liveSocket = new LiveSocket("/live", Socket, {params: {_csrf_token: csrfToken}})

// Show progress bar on live navigation and form submits
topbar.config({barColors: {0: "#29d"}, shadowColor: "rgba(0, 0, 0, .3)"})
window.addEventListener("phx:page-loading-start", info => topbar.show())
window.addEventListener("phx:page-loading-stop", info => topbar.hide())

// connect if there are any LiveViews on the page
liveSocket.connect()

// expose liveSocket on window for web console debug logs and latency simulation:
// >> liveSocket.enableDebug()
// >> liveSocket.enableLatencySim(1000)  // enabled for duration of browser session
// >> liveSocket.disableLatencySim()
window.liveSocket = liveSocket



// custom

function goToPage() {
  var path = window.location.href
  var page = prompt("Enter the per_page value:");
  if (page != null) {
    window.location.href = path + "&per_page=" + page;
  }
};

if (document.getElementById("redirect-button") != null) {
  document.getElementById("redirect-button").addEventListener("click", function() {
    goToPage();
  });
};

const fileInput = document.getElementById('file-input');
const fileInputPlaceholder = document.getElementById('file-input-placeholder');
const filePreviewContainer = document.getElementById('file-preview-container');

if (fileInput != null) {
  fileInput.addEventListener('change', (event) => {
    const file = event.target.files[0];
    if (file) {
      fileInputPlaceholder.style.display = 'none';
      const reader = new FileReader();
      reader.onload = (event) => {
        const preview = document.createElement('div');
        preview.id = 'file-preview';
        const img = document.createElement('img');
        img.src = event.target.result;
        const span = document.createElement('span');
        span.innerText = file.name;
        const button = document.createElement('button');
        button.innerText = 'Remove';
        button.addEventListener('click', () => {
          preview.remove();
          fileInput.value = '';
          fileInputPlaceholder.style.display = 'flex';
        });
        preview.appendChild(img);
        preview.appendChild(span);
        preview.appendChild(button);
        filePreviewContainer.appendChild(preview);
      };
      reader.readAsDataURL(file);
    }
  });

  fileInputPlaceholder.addEventListener('dragover', (event) => {
    event.preventDefault();
    event.stopPropagation();
    fileInputPlaceholder.style.border = '2px solid gray';
  });

  fileInputPlaceholder.addEventListener('dragleave', (event) => {
    event.preventDefault();
    event.stopPropagation();
    fileInputPlaceholder.style.border = '2px dashed gray';
  });

  fileInputPlaceholder.addEventListener('drop', (event) => {
    event.preventDefault();
    event.stopPropagation();
    fileInput.files = event.dataTransfer.files;
    fileInputPlaceholder.style.border = '2px dashed gray';
    const changeEvent = new Event('change');
    fileInput.dispatchEvent(changeEvent);
  });
};




