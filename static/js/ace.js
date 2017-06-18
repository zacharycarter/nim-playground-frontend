ace.require("ace/split");

var editor = ace.edit("editor");
editor.setTheme("ace/theme/monokai");
editor.getSession().setMode("ace/mode/python");
editor.setAutoScrollEditorIntoView(true);
editor.getSession().setUseWrapMode(true);
editor.resize();

var editorEle = document.getElementById("editor")
editorEle.editor = editor;

editorEle.getEditor = function() {
    return this.editor;
}

function getUrlParameter(name) {
    name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
    var regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
    var results = regex.exec(location.search);
    return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
};

editorEle.editor.setValue(getUrlParameter('code'));