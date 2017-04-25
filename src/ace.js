ace.require("ace/split");

var editor = ace.edit("editor");
editor.setTheme("ace/theme/monokai");
editor.getSession().setMode("ace/mode/javascript");
editor.setAutoScrollEditorIntoView(true);
editor.maxLines = 100;
editor.getSession().setUseWrapMode(true);

var editorEle = document.getElementById("editor")
editorEle.editor = editor;

editorEle.getEditor = function() {
    return this.editor;
}