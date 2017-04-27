import karax, karaxdsl, vdom, kajax, json, strutils
import dom except Event

type
  CompileResponse = object
    compileLog: string
    log: string

var loading = ""

proc getValue(n: Node): cstring {.importcpp: "#.getValue()".}
proc setValue(n: Node, text: cstring) {.importcpp: "#.setValue()".}
proc getEditor(n: Node): Node {.importcpp: "#.getEditor()".}
proc `value=`(n: Node, text: cstring) {.importcpp: "#.value = #".}

proc cb (httpStatus: int, response: cstring) =
  if httpStatus == 200:
    loading = ""
    let parsed = parseJson($response)
    let compileResponse = to(parsed, CompileResponse)
    var compileLogContainer = document.getElementById("compile-log")
    var compileLog = document.getElementById("compile-log-content")
    if compileResponse.compileLog.contains "Success":
      compileLogContainer.classList.remove("is-dark")
      compileLogContainer.classList.remove("is-danger")
      compileLogContainer.classList.add("is-success")
    else:
      compileLogContainer.classList.remove("is-dark")
      compileLogContainer.classList.remove("is-success")
      compileLogContainer.classList.add("is-danger")      

    compileLog.innerHtml = compileResponse.compileLog

    var programLogContainer = document.getElementById("program-log")
    var programLog = document.getElementById("program-log-content")
    programLogContainer.classList.remove("is-dark")
    programLogContainer.classList.add("is-info")
    programLog.innerHtml = compileResponse.log

proc clear(ev: Event; n: VNode) =
  let ele = document.getElementById("editor")
  ele.getEditor().setValue("")

proc compile(ev: Event; n: VNode) =
  var compileLogContainer = document.getElementById("compile-log")
  var compileLog = document.getElementById("compile-log-content")
  var programLogContainer = document.getElementById("program-log")
  var programLog = document.getElementById("program-log-content")
  compileLog.innerHtml = ""
  compileLogContainer.classList.remove("is-success")
  compileLogContainer.classList.remove("is-danger")
  compileLogContainer.classList.add("is-dark")
  programLog.innerHtml = ""
  programLogContainer.classList.remove("is-info")
  programLogContainer.classList.add("is-dark")
  

  let ele = document.getElementById("editor")
  let req = %* {"code": $ele.getEditor().getValue()}
  loading = "is-loading"
  ajaxPost("/compile", @[], ($req).cstring, cb)
  

proc createDom(): VNode =
  result = buildHtml(tdiv(class="container", id="wrapper")):
    nav(class="nav"):
      tdiv(class="nav-left"):
        a(class="nav-item", href="https://nim-lang.org"):
          img(src="static/img/logo.svg", alt="Nim logo")
        tdiv(class="nav-right"):
          tdiv(class="heading", id="playground-logo-container"):
            h1(class="title", id="playground-logo"):
              text "Playground"
    tdiv(class="hero"):
      tdiv(class="hero-body"):
        tdiv(class="container"):
          h1(class="title"):
            text "Compile"
          h2(class="subtitle"):
            text "Snippets of Nim in your browser"
    tdiv(class="section"):
      tdiv(class="tile is-ancestor"):
        tdiv(class="tile is-parent editor-wrapper"):
          tdiv(class="tile is-child box"):
            tdiv(class="editor-container"):
              tdiv(id="editor")
        tdiv(class="tile is-vertical is-parent"):
          tdiv(class="tile is-child"):
            article(class="message is-dark", id="compile-log"):
              tdiv(class="message-header"):
                text "Compile Log"
              tdiv(class="message-body"):
                pre(id="compile-log-content")
          tdiv(class="tile is-child"):
            article(class="message is-dark", id="program-log"):
              tdiv(class="message-header"):
                text "Program Result"
              tdiv(class="message-body"):
                pre(id="program-log-content")
        #tdiv(class="hero-foot"):
      tdiv(class="columns"):
        tdiv(class="column is-narrow"):
          button(class="button is-primary $1" % loading, onclick=compile):
            text "Compile"
        tdiv(class="column is-narrow"):
          button(class="button", onclick=clear):
            text "Clear"

    script(src = "static/js/ace.js")

setRenderer createDom