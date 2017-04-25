import karax, karaxdsl, vdom, kajax, json
import dom except Event

type
  CompileResponse = object
    compileLog: string
    log: string


proc getValue(n: Node): cstring {.importcpp: "#.getValue()".}
proc setValue(n: Node, text: cstring) {.importcpp: "#.setValue()".}
proc getEditor(n: Node): Node {.importcpp: "#.getEditor()".}
proc resize(n: Node) {.importcpp: "#.resize()".}
proc `value=`(n: Node, text: cstring) {.importcpp: "#.value = #".}

proc cb (httpStatus: int, response: cstring) =
  if httpStatus == 200:
    let parsed = parseJson($response)
    let compileResponse = to(parsed, CompileResponse)
    var compileLog = document.getElementById("compile-log")
    var programLog = document.getElementById("program-result")
    compileLog.value = compileResponse.compileLog
    programLog.value = compileResponse.log

proc clear(ev: Event; n: VNode) =
  let ele = document.getElementById("editor")
  ele.getEditor().setValue("")

proc resize(ev: Event; n: VNode) =
  let ele = document.getElementById("editor")
  ele.getEditor().resize()

proc compile(ev: Event; n: VNode) =
  var compileLog = document.getElementById("compile-log")
  var programLog = document.getElementById("program-result")
  compileLog.value = ""
  programLog.value = ""
  let ele = document.getElementById("editor")
  let req = %* {"code": $ele.getEditor().getValue()}
  ajaxPost("http://localhost:5000/compile", @[], ($req).cstring, cb)

proc createDom(): VNode =
  result = buildHtml(tdiv(class="app-wrapper")):
    section(class = "app"):
      header(class = "header")
      section(class = "main"):
        tdiv(class="container"):
          tdiv(class="columns"):
            tdiv(class="column col-8", id="editor-container"):
              tdiv(id="editor", class="pt-10")
              tdiv(class="pt-10"):
                button(class="btn mt-5 mr-5", onclick=compile):
                  text "Submit"
                button(class="btn mt-5", onclick=clear):
                  text "Clear"


            tdiv(class="column col-4"):
              form:
                tdiv(class="form-group"):
                  label(class="form-label", `for`="input-compile-log"):
                    text "Compiler Log:"
                  textarea(class="form-input", id="compile-log", rows="10", onmouseup=resize)
                  label(class="form-label", `for`="program-result"):
                    text "Program Result:"
                  textarea(class="form-input", id="program-result", rows="10", onmouseup=resize)
              
                
      footer(class = "footer")

setRenderer createDom
loadScript "src/ace.js"
