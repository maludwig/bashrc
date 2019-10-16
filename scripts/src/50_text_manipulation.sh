function upper { cat - | tr '[:lower:]' '[:upper:]'; }
function lower { cat - | tr '[:upper:]' '[:lower:]'; }