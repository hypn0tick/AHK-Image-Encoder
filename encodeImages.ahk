#Requires AutoHotkey >=2.0-

; Include the Neutron library
#Include Lib\Neutron.ahk
#Include Lib\ImagePut.ahk

titleStartGui := "AutoHotkey Image Encoder"
titleDataGui := "Encoded Image Data"

; Initialize GUI objects:
startGui := NeutronWindow()
  .OnEvent("Close", (startGui) => ExitApp())
dataGui := NeutronWindow()
  .OnEvent("Close", (dataGui) => ExitApp())

htmlStartGui := "
( ; html
  <h1 style="text-align:center">Base64 Image Encoder</h1>
  <p>
    This script provides a useful set of tools for encoding and importing images
    in AutoHotkey. It leverages the <a style="color:#6CB4EE" href="https://github.com/iseahound/ImagePut">ImagePut</a> 
    library for encoding, and has the ability to convert images into a ".ahk" file that can be
    easily imported into another script.
    <br><br>
    I highly recommend using the <a style="color:#6CB4EE" href="https://github.com/iseahound/ImagePut">ImagePut</a>
    library in your own script to convert the encoded data back into images.
  </p>
  <div style="display:flex;justify-content:center;">
    <button onclick="ahk.selectImages(event)">
      <svg id="start-icon" class="start-icon" viewBox="0 0 256 256">
        <path d="M 16.000736,48.000563 A 31.999783,31.999783 0 0 1 48.000519,16.000782"/>
        <path d="M 239.99926,48.000563 A 31.999783,31.999783 0 0 0 207.99948,16.000782"/>
        <path d="m 239.99926,207.99947 a 31.999783,31.999783 0 0 1 -31.99978,31.99978"/>
        <path d="m 16.000736,207.99947 a 31.999783,31.999783 0 0 0 31.999783,31.99978"/>
        <path d="m 239.99923,143.99987 v 31.9998"/>
        <path d="M 239.99923,80.000312 V 112.00011"/>
        <path d="m 16.000747,143.99991 v 31.99976"/>
        <path d="M 16.000751,80.000312 V 112.00011"/>
        <path d="M 112.00008,16.000744 H 80.000284"/>
        <path d="M 175.99964,16.000748 H 143.99988"/>
        <path d="M 112.00008,239.99922 H 80.000284"/>
        <path d="M 175.99964,239.99922 H 143.99988"/>
        <path d="M 96.000202,127.99999 H 159.99976"/>
        <path d="M 128,96.000192 V 159.99979"/>
      </svg>
      Select Images
    </button>
  </div>
)"

cssStartGui := "
( ; css
  header {
    background: #333;
    color: white;
    text-align: left;
  }
  .main {
    background: #444;
    color: white;
    text-align: justify;
    ;text-justify: inter-word;
  }
  button {
    cursor: pointer;
    display: flex;
    background: slategray;
    border: none;
    color: white;
    border-radius: 0.5em;
    padding: 0.75em 0.75em;
    justify-content: center;
    align-items: center;
  }
  .start-icon {
    fill: none;
    stroke: white;
    stroke-width: 16px;
    margin-right: 0.5em;
    width: 2em;
    height: 2em;
  }
)"

; Gui Functions & Events:
copyText(event, text) {
  A_Clipboard := text
}

createImportFile(event, fileData) {
  filePath := FileSelect("S 16", "ImageData.ahk", "Image Data Output File", "AutoHotkey Script (*.ahk)")
  if (!filePath) {
    return
  }
  else {
    outputFile := FileOpen(filePath, "w -wd `n")
    fileData := StrReplace(fileData, "'", '"')
    fileData := StrReplace(fileData, "``n", "`n")
    fileData := StrReplace(fileData, "``t", "`t")
    outputFile.Write(fileData)
    outputFile.Close()
    confirmationDialogue(filePath)
    return filePath
  }
}

selectImages(neutron, event) {
  startGui.hide()
  files := FileSelect("M S3",,"Select Images to Convert to Base64","Images (*.bmp; *.dib; *.rle; *.jpg; *.jpeg; *.jpe; *.jfif; *.gif; *.emf; *.wmf; *.tif; *.tiff; *.png; *.ico; *.heic; *.hif; *.webp; *.avif; *.avifs; *.pdf; *.svg)")

  data := Map()
  fileData := "imageData(image := \'\') {``n"
  fileData .= "``tdata := map()``n"

  ; HTML generation based on selected images:
  htmlDataGui .= '<div class="container" id="content">'

  for (item in files) {
    SplitPath item, &nameLong,,,&name
    data[name] := ImagePutBase64(item)
    fileData .= "``tdata[\'" name "\'] := \'``n``t(Join``n``t" data[name] "``n``t)\'``n"

    htmlDataGui .= '<div class="box">'
    htmlDataGui .= '<div class="inline">'
    htmlDataGui .= '<div class="left">'
    htmlDataGui .= NeutronWindow.FormatHTML('<h4 style="padding: 0.5em;margin: 0.5em;">{}</h4>', nameLong)
    htmlDataGui .= "</div>"
    htmlDataGui .= '<div class="right">'
    htmlDataGui .= "<button onclick=`"ahk.copyText('" data[name] "')`">"
    htmlDataGui .= '<svg id="copy-icon" class="copy-icon" viewBox="0 0 64 64">'
    htmlDataGui .= '<path d="M53.9791489,9.1429005H50.010849c-0.0826988,0-0.1562004,0.0283995-0.2331009,0.0469999V5.0228 C49.7777481,2.253,47.4731483,0,44.6398468,0h-34.422596C7.3839517,0,5.0793519,2.253,5.0793519,5.0228v46.8432999 c0,2.7697983,2.3045998,5.0228004,5.1378999,5.0228004h6.0367002v2.2678986C16.253952,61.8274002,18.4702511,64,21.1954517,64 h32.783699c2.7252007,0,4.9414978-2.1725998,4.9414978-4.8432007V13.9861002 C58.9206467,11.3155003,56.7043495,9.1429005,53.9791489,9.1429005z M7.1110516,51.8661003V5.0228 c0-1.6487999,1.3938999-2.9909999,3.1062002-2.9909999h34.422596c1.7123032,0,3.1062012,1.3422,3.1062012,2.9909999v46.8432999 c0,1.6487999-1.393898,2.9911003-3.1062012,2.9911003h-34.422596C8.5049515,54.8572006,7.1110516,53.5149002,7.1110516,51.8661003z M56.8888474,59.1567993c0,1.550602-1.3055,2.8115005-2.9096985,2.8115005h-32.783699 c-1.6042004,0-2.9097996-1.2608986-2.9097996-2.8115005v-2.2678986h26.3541946 c2.8333015,0,5.1379013-2.2530022,5.1379013-5.0228004V11.1275997c0.0769005,0.0186005,0.1504021,0.0469999,0.2331009,0.0469999 h3.9682999c1.6041985,0,2.9096985,1.2609005,2.9096985,2.8115005V59.1567993z"/>'
    htmlDataGui .= '<path d="M38.6031494,13.2063999H16.253952c-0.5615005,0-1.0159006,0.4542999-1.0159006,1.0158005 c0,0.5615997,0.4544001,1.0158997,1.0159006,1.0158997h22.3491974c0.5615005,0,1.0158997-0.4542999,1.0158997-1.0158997 C39.6190491,13.6606998,39.16465,13.2063999,38.6031494,13.2063999z"/>'
    htmlDataGui .= '<path d="M38.6031494,21.3334007H16.253952c-0.5615005,0-1.0159006,0.4542999-1.0159006,1.0157986 c0,0.5615005,0.4544001,1.0159016,1.0159006,1.0159016h22.3491974c0.5615005,0,1.0158997-0.454401,1.0158997-1.0159016 C39.6190491,21.7877007,39.16465,21.3334007,38.6031494,21.3334007z"/>'
    htmlDataGui .= '<path d="M38.6031494,29.4603004H16.253952c-0.5615005,0-1.0159006,0.4543991-1.0159006,1.0158997 s0.4544001,1.0158997,1.0159006,1.0158997h22.3491974c0.5615005,0,1.0158997-0.4543991,1.0158997-1.0158997 S39.16465,29.4603004,38.6031494,29.4603004z"/>'
    htmlDataGui .= '<path d="M28.4444485,37.5872993H16.253952c-0.5615005,0-1.0159006,0.4543991-1.0159006,1.0158997 s0.4544001,1.0158997,1.0159006,1.0158997h12.1904964c0.5615025,0,1.0158005-0.4543991,1.0158005-1.0158997 S29.0059509,37.5872993,28.4444485,37.5872993z"/>'
    htmlDataGui .= "</svg>"
    htmlDataGui .= "</button>"
    htmlDataGui .= "</div>"
    htmlDataGui .= "</div>"

    htmlDataGui .= "<div class=`"row`">"
    htmlDataGui .= NeutronWindow.FormatHTML(data[name])
    htmlDataGui .= "</div></div>"
  }

  htmlDataGui .= "</div>"

  fileData .= "``tif (image = \'\' || image = \'all\' || image = \'*\')``n"
  fileData .= "``t``treturn data``n"
  fileData .= "``telse``n"
  fileData .= "``t``treturn data[image]``n}"

  htmlDataGui .= "<createFileButton id=`"createFileButton`" onclick=`"ahk.createImportFile('" fileData "')`">"
  htmlDataGui .= '<svg id="create-file-icon" class="create-file-icon" viewBox="0 0 24 24">'
    htmlDataGui .= '<path d="M10 15H14M12 13V17M13 3H8.2C7.0799 3 6.51984 3 6.09202 3.21799C5.71569 3.40973 5.40973 3.71569 5.21799 4.09202C5 4.51984 5 5.0799 5 6.2V17.8C5 18.9201 5 19.4802 5.21799 19.908C5.40973 20.2843 5.71569 20.5903 6.09202 20.782C6.51984 21 7.0799 21 8.2 21H15.8C16.9201 21 17.4802 21 17.908 20.782C18.2843 20.5903 18.5903 20.2843 18.782 19.908C19 19.4802 19 18.9201 19 17.8V9M13 3L19 9M13 3V7.4C13 7.96005 13 8.24008 13.109 8.45399C13.2049 8.64215 13.3578 8.79513 13.546 8.89101C13.7599 9 14.0399 9 14.6 9H19"/>'
  htmlDataGui .= '</svg>'
  htmlDataGui .= "Create Import File"
  htmlDataGui .= "</createFileButton>"

  htmlDataGui .= "<backButton onclick=`"ahk.start()`">"
  htmlDataGui .= '<svg id="back-icon" class="back-icon" viewBox="0 0 24 24">'
    htmlDataGui .= '<path fill-rule="evenodd" clip-rule="evenodd" d="M6.75 5.25V18.75H8.25L8.25 5.25H6.75ZM9.14792 12L18 17.9014L18 6.09862L9.14792 12ZM16.5 8.9014L16.5 15.0986L11.8521 12L16.5 8.9014Z"/>'
  htmlDataGui .= '</svg>'
  htmlDataGui .= "</createFileButton>"

  cssDataGui := "
  ( ; css
      body {
        width: 100%;
        height: 100%;
        font-family: sans-serif;
      }
      body {
        display: flex;
        flex-direction: column;
      }
      header {
        width: 100%;
        display: flex;
        background: #333;
        color: white;
        font-family: Segoe UI;
        font-size: 9pt;
      }
      .main {
        font-size: 12pt;
        padding: 1em;
        overflow: auto;
        background: #444;
        color: white;
      }
      .inline {
        display: flex;
        width: 100%
        flex-direction: row;
        vertical-align: middle;
      }
      .box {
        display: flex;
        flex-direction: column;
        max-width: 600px;
        max-height: 200px;
        border: 2px solid black;
        padding: 0.25em 0.25em;
        margin: 0.25em 0.25em;
      }
      .container {
        display: block;
        padding: 0;
        margin: 2em 0;
      }
      .row {
        padding: 1em;
        margin: 1em;
        display: flex;
        font-size: 8pt;
        max-height: 50px;
        flex-wrap: wrap;
        flex-direction: column;
        background: rgba(0, 0, 0, .2);
        word-break: break-all;
        justify-content: space-between;
        border: 1px solid black;
        overflow: auto;
      }
      button {
        background: slategray;
        border: none;
        color: white;
        margin: 0.5em 0.5em;
        padding: 0.25em 0.5em;
        border-radius: 0.25em;
      }
      backButton {
        display: flex;
        cursor: pointer;
        position: fixed;
        top: 1.5em;
        left: 1em;
        border: none;
        color: white;
        margin: 0.25em 0;
        padding: 0.25em 0;
        border-radius: 0.5em;
        justify-content: center;
        align-items: center;
        vertical-align: middle;
      }
      .back-icon {
        fill: white;
        stroke-width: 1;
        stroke-linecap: round;
        stroke-linejoin: round;
        margin-right: 0.25em;
        width: 2em;
        height: 2em;
      }
      createFileButton {
        display: flex;
        cursor: pointer;
        background: #17B169;
        position: fixed;
        top: 1.5em;
        right: 1em;
        border: none;
        color: white;
        margin: 0.25em 0.5em;
        padding: 0.25em 0;
        padding-right: 0.3em;
        border-radius: 0.5em;
        justify-content: center;
        align-items: center;
        vertical-align: middle;
      }
      .create-file-icon {
        fill: none;
        stroke: white;
        stroke-width: 1;
        stroke-linecap: round;
        stroke-linejoin: round;
        margin-right: 0.25em;
        width: 2em;
        height: 2em;
      }
      .right {
        margin-left: auto;
        vertical-align: middle;
      }
      .left {
        margin-right: auto;
        vertical-align: middle;
      }
      copyButton {
        cursor: pointer;
        border: none;
        color: white;
        background: slategray;
        border-radius: 0.5em;
      }
      .copy-icon {
        fill: white;
        padding: 0.2em 0em;
        width: 1.5em;
        height: 1.5em;
        vertical-align: middle;
        align-items: center;
        justify-content: center;
    }
  )"

  if (files.length = 0) {
    startGui.show()
  }

  global dataGui := NeutronWindow(htmlDataGui, cssDataGui,, titleDataGui)
    .OnEvent("Close", (dataGui) => ExitApp())
    .Show("w640 h480", "Template")
}

confirmationDialogue(filePath) {
  content := ""

  html := '<div class="container">'
  ;html .= NeutronWindow.FormatHTML(content)
  html .= "Import file created successfully!<br><br>"
  html .= "Usage:<hr>"
  html .= "<ol>"
    html .= "<li>Import the image data into your script:<br><code>#Include `"" filePath "`"</code></li><br>"
    html .= "<li>Call upon the image data in one of two ways:"
      html .= "<ul>"
        html .= "<li>Call a specific image's encoded data:<br><code>imageData(IMAGE_NAME)</code></li><br>"
        html .= "<li>Create a map object/array with all of the images' data:<br><code>data := imageData()</code></li>"
      html .= "</ul>"
    html .= "</li>"
  html .= "</ol>"
  html .= '</div>'
  html .= '<div class="footer">'
  html .= "<button onclick=`"ahk.exit()`">OK</button>"
  html .= '</div>'

  css := "
  ( ; css
    header {
      background: #333;
      color: white;
      text-align: left;
    }
    .main {
      background: #444;
      color: white;
    }
    .container {
      width: 100%;
      display: flex;
      flex-wrap: wrap;
      flex-direction: column;
      border: none;
      color: white;
      flex-direction: column;
      text-align: justify;
      justify-content: left;
      text-align: left;
      align-items: left;
      overflow: auto;
    }
    .footer {
      position: fixed;
      left: 0;
      bottom: 0;
      width: 100%;
      color: white;
      text-align: center;
      justify-content: center;
    }
    button {
      width: 50%;
      background: slategray;
      border: none;
      color: white;
      margin: 0.5em 0.5em;
      padding: 0.25em 0.5em;
      border-radius: 0.25em;
    }
  )"

  confirmationGui := NeutronWindow(html, css,, "File Created Successfully!")
    .OnEvent("Close", (confirmationGui) => confirmationGui.Hide())
    .Show("w640 h560", "Template")
}

start(*) {
  if (dataGui) {
    dataGui.Hide()
  }
  global startGui := NeutronWindow(htmlStartGui, cssStartGui,, titleStartGui)
    .OnEvent("Close", (startGui) => ExitApp())
    .Show("w680 h500", "Template")
  return startGui
}

start()