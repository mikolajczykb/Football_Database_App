const deleteRow = async (url, id) => {
    
    const response = await fetch(url + '/' + id, {
        method: 'DELETE',
        headers: {
            'Content-Type': 'application/json'
        }
    })
    console.log(response);
    window.location.href = "/players";
    /*response.json().then(json => {
        
    }).catch((err) => {
        console.log(err);
    })*/
}

/*const updateRow = (url, id, data) => {

    fetch(url + '/' + id), {
        method: 'PUT',
        headers: {
            'Content-Type': 'application/json'
        },
        body: JSON.stringify(data)
    }
}*/

showForm = () => {
    if ($("#addForm").css("display") === "none") {
        $("#addForm").css("display", "inline");
    } else {
        $("#addForm").css("display", "none");
    }
    $("result").html("");
}

const setTopPos = function() {
	var currPos = window.pageYOffset;
    var sidebar = document.getElementById("sidebar");
    var finalPos = 0;
	finalPos = currPos > 240 ? (currPos + window.innerHeight / 3).toString() + "px" : "480px";
    sidebar.style.top = finalPos.toString();
}

window.onscroll = function() {
	setTopPos();
}


