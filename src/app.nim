import karax, karaxdsl, vdom, kajax, json, strutils
import dom except Event

type
  CompileResponse = object
    compileLog: string
    log: string

var loading = ""
var gistLoading = ""
var gistModalActive = ""
var gistLink = ""
var shareLink = ""

proc getValue(n: Node): cstring {.importcpp: "#.getValue()".}
proc setValue(n: Node, text: cstring, cursorPos: SomeNumber) {.importcpp: "#.setValue()".}
proc getEditor(n: Node): Node {.importcpp: "#.getEditor()".}
proc selectedIndex(n: Node): cint {.importcpp: "#.selectedIndex".}

proc gistCB (httpStatus: int, response: cstring) =
  if httpStatus == 200:
    let responseParts = split($response, "/")
    gistLoading = ""
    gistLink = $response
    shareLink = "https://play.nim-lang.org?gist=$1" % responseParts[responseParts.len - 1]
    gistModalActive = "is-active"

proc cb (httpStatus: int, response: cstring) =
  if httpStatus == 200:
    loading = ""
    let parsed = parseJson($response)
    let compileResponse = to(parsed, CompileResponse)
    var compileLogContainer = document.getElementById("compile-log")
    var compileLog = document.getElementById("compile-log-content")
    if compileResponse.compileLog.contains "Success":
      compileLogContainer.classList.add("is-success")
    else:
      compileLogContainer.classList.add("is-danger")      

    compileLog.innerHtml = compileResponse.compileLog

    var programLogContainer = document.getElementById("program-log")
    var programLog = document.getElementById("program-log-content")
    programLogContainer.classList.add("is-info")
    programLog.innerHtml = compileResponse.log

proc closeGistModal(ev: Event; n: VNode) =
  gistModalActive = ""
  gistLink = ""
  shareLink = ""

proc gist(ev: Event; n: VNode) =
  let ele = document.getElementById("editor")
  let compilationTargetEle = document.getElementById("compilationTarget")
  let compilationTarget = compilationTargetEle.options[compilationTargetEle.selectedIndex].value
  let req = %* {"code": $ele.getEditor().getValue(), "compilationTarget": $compilationTarget }
  gistLoading = "is-loading"
  ajaxPost("/gist", @[], ($req).cstring, gistCb)

proc clear(ev: Event; n: VNode) =
  let ele = document.getElementById("editor")
  ele.getEditor().setValue("", -1)

proc compile(ev: Event; n: VNode) =
  var compileLogContainer = document.getElementById("compile-log")
  var compileLog = document.getElementById("compile-log-content")
  var programLogContainer = document.getElementById("program-log")
  var programLog = document.getElementById("program-log-content")
  compileLog.innerHtml = ""
  compileLogContainer.classList.remove("is-success")
  compileLogContainer.classList.remove("is-danger")
  programLog.innerHtml = ""
  programLogContainer.classList.remove("is-info")

  let compilationTargetEle = document.getElementById("compilationTarget")
  let compilationTarget = compilationTargetEle.options[compilationTargetEle.selectedIndex].value
  

  let ele = document.getElementById("editor")
  let req = %* {"code": $ele.getEditor().getValue(), "compilationTarget": $compilationTarget }
  loading = "is-loading"
  ajaxPost("/compile", @[], ($req).cstring, cb)
  

proc createDom(): VNode =
  result = buildHtml(tdiv(class="container", id="wrapper")):
    nav(class="nav has-shadow"):
      tdiv(class="nav-left"):
        a(class="nav-item", href="https://play.nim-lang.org"):
          img(src="static/img/logo.svg", alt="Nim logo")
          tdiv(class="heading", id="playground-logo-container"):
            h1(class="title is-hidden-mobile", id="playground-logo"):
              text "| Playground"
        
    tdiv(class="section is-flex-mobile", id="main"):
      tdiv(id="title"):
        h1(class="title"):
          text "Compile & Run"
        h2(class="subtitle"):
          text "Snippets of Nim in your browser"
      tdiv(id="menu"):
        button(class="button $1 menuItem" % gistLoading, onclick=gist):
          text "Create Gist"
        select(id="compilationTarget", class="menuItem"):
          option(value="c", selected="selected"):
            text "C"
          option(value="cpp"):
            text "C++"
      tdiv(class="tile is-ancestor"):
        tdiv(class="tile is-parent"):
          tdiv(class="tile is-child box editor-wrapper"):
            tdiv(class="editor-container"):
              tdiv(id="editor")
        tdiv(class="tile is-vertical is-parent is-flex-mobile", id="logs"):
          tdiv(class="tile is-child log-container"):
            article(class="message is-dark", id="compile-log"):
              tdiv(class="message-header"):
                text "Compile Log"
              pre(class="message-body", id="compile-log-content")
          tdiv(class="tile is-child log-container"):
            article(class="message is-dark", id="program-log"):
              tdiv(class="message-header"):
                text "Program Result"
              pre(class="message-body", id="program-log-content")
      tdiv(class="columns is-flex-mobile"):
        tdiv(class="column is-narrow"):
          button(class="button is-primary $1" % loading, onclick=compile):
            text "Compile"
        tdiv(class="column is-narrow"):
          button(class="button", onclick=clear):
            text "Clear"
        tdiv(class="modal $1" % gistModalActive, id="gist"):
          tdiv(class="modal-background", onclick=closeGistModal)
          tdiv(class="modal-content"):
            tdiv(class="box"):
              article(class="media"):
                tdiv(class="media-content"):
                  tdiv(class="content"):
                    h2(class="subtitle"):
                      text "Link to gist:"
                    a(href=gistLink):
                      text gistLink
                    h2(class="subtitle"):
                      text "Shareable link:"
                    a(href=shareLink):
                      text shareLink

          button(class="modal-close is-large", onclick=closeGistModal)
    script(src = "static/js/ace.js")

setRenderer createDom