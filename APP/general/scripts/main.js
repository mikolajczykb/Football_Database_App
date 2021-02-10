const deleteRow = async (url, id) => {
    
    try {
        const response = await fetch(url + '/' + id, {
            method: 'DELETE',
            headers: {
                'Content-Type': 'application/json'
            }
        });
        jsonOBJ = await response.json();
        alert(jsonOBJ["message"]);
        window.location.href = "/" + url;
    } catch (error) {
        console.log(error);
    }
    /*response.json().then(json => {
        
    }).catch((err) => {
        console.log(err);
    })*/
}

const updateRow = async (url, form) => {
    /*data = {};
    const playerId = form.playerId.value;
    data.shirtNumber = form.shirtNumber.value;
    data.name = form.name.value;
    data.surname = form.surname.value;*/
    data = new FormData(document.getElementById("updateForm"));
    const Id = form.Id.value;
    try {
        const response = await fetch(url + '/' + Id, {
            method: 'POST',
            /*headers: {
                'Content-Type': 'application/json'
            },*/
            //body: JSON.stringify(data)
            body: data
        });
        jsonOBJ = await response.json();
        alert(jsonOBJ["message"]);
        window.location.href = "/" + url;
        
    } catch (error) {
        console.error(error);
    }
    
};

const showForm = () => {
    if ($("#addForm").css("display") === "none") {
        $("#addForm").css("display", "inline");
    } else {
        $("#addForm").css("display", "none");
    }
    $("#updateForm").css("display", "none");
    $("result").html("");
}

var idToUpdate;

const updateForm = (id) => {
    idToUpdate = id;
    $("#Id").val(idToUpdate);

    if ($("#updateForm").css("display") === "none") {
        $("#updateForm").css("display", "inline");
    } else {
        $("#updateForm").css("display", "none");
    }
    $("#addForm").css("display", "none");
    $("result").html("");
}

/*const setTopPos = function() {
    var currPos = window.pageYOffset;
    var sidebar = document.getElementById("sidebar");
    if (sidebar) {
        var finalPos = 0;
        finalPos = currPos > 240 ? (currPos + window.innerHeight / 3).toString() + "px" : "480px";
        sidebar.style.top = finalPos.toString();    
    }
}

window.onscroll = function() {
    setTopPos();
}
*/
const setLeftPos = function() {
    var divWidth = $(".container").width();
    var screenWidth = $(window).width();
	$("#sidebar").css("left", (((screenWidth - divWidth) / 16).toString() + "px"));
}

window.onload = setLeftPos();
window.onresize = setLeftPos();
