ace.require("ace/split");

var editor = ace.edit("editor");
editor.setTheme("ace/theme/monokai");
editor.getSession().setMode("ace/mode/python");
editor.setAutoScrollEditorIntoView(true);
editor.getSession().setUseWrapMode(true);

var editorEle = document.getElementById("editor")
editorEle.editor = editor;

editorEle.getEditor = function() {
    return this.editor;
}