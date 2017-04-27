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
  result = buildHtml(tdiv(class="container")):
    section(class="hero is-fullheight"):
      nav(class="nav"):
        tdiv(class="nav-left"):
          a(class="nav-item", href="https://nim-lang.org"):
            img(src="https://nim-lang.org/assets/img/logo.svg", alt="Nim logo")
      #hr()
      tdiv(class="hero-body"):
        tdiv(class="heading"):
          h1(class="title"):
            text "Playground"
          h2(class="subtitle"):
            text "Execute snippets of "
            strong:
              text "Nim"
            text " code from your browser"
        tdiv(class="tile is-ancestor"):
          tdiv(class="tile is-parent"):
            tdiv(class="tile is-child box"):
              tdiv(class="editor-container"):
                tdiv(id="editor")
          tdiv(class="tile is-vertical is-parent"):
            tdiv(class="tile is-child box"):
              article(class="message is-dark", id="compile-log"):
                tdiv(class="message-header"):
                  text "Compile Log"
                tdiv(class="message-body", id="compile-log-content")
            tdiv(class="tile is-child box"):
              article(class="message is-dark", id="program-log"):
                tdiv(class="message-header"):
                  text "Program Result"
                tdiv(class="message-body", id="program-log-content")
      tdiv(class="columns"):
        tdiv(class="column is-narrow"):
          button(class="button $1" % loading, onclick=compile):
            text "Compile"
        tdiv(class="column is-narrow"):
          button(class="button", onclick=clear):
            text "Clear"
    script(src = "src/ace.js")

setRenderer createDom