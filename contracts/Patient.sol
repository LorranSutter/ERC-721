// SPDX-License-Identifier: MIT

pragma solidity ^0.6.0;

import "./ERC721.sol";


contract Patient is ERC721("Patient", "PNT") {
    enum Status {Fair, Critical}

    struct PatientInfo {
        string name;
        uint64 dateBirth;
        Status status;
        address emergencyHospital;
    }

    mapping(uint256 => PatientInfo) patients;

    modifier onlyHolder(uint256 _patientId) {
        require(
            msg.sender == patientHolder(_patientId),
            "Patient: not hospital holder"
        );
        _;
    }

    function totalPatients() public view returns (uint256) {
        return super.totalSupply();
    }

    function patientHolder(uint256 _patientId) public view returns (address) {
        return super.ownerOf(_patientId);
    }

    function getPatientName(uint256 _patientId)
        public
        view
        onlyHolder(_patientId)
        returns (string memory)
    {
        return patients[_patientId].name;
    }

    function getPatientDateBirth(uint256 _patientId)
        public
        view
        onlyHolder(_patientId)
        returns (uint64)
    {
        return patients[_patientId].dateBirth;
    }

    function getPatientStatus(uint256 _patientId)
        public
        view
        onlyHolder(_patientId)
        returns (Status)
    {
        return patients[_patientId].status;
    }

    function getPatientEmergencyHospital(uint256 _patientId)
        public
        view
        onlyHolder(_patientId)
        returns (address)
    {
        return patients[_patientId].emergencyHospital;
    }

    function addPatient(
        string memory _name,
        uint64 _dateBirth,
        address _emergencyHospital
    ) public {
        uint256 tokenId = mint(msg.sender);

        patients[tokenId] = PatientInfo(
            _name,
            _dateBirth,
            Status.Fair,
            _emergencyHospital
        );
    }

    function transferPatient(address _to, uint256 _patientId) public {
        _transferPatientFrom(msg.sender, _to, _patientId);
    }

    function movePatientToCritical(uint256 _patientId)
        public
        onlyHolder(_patientId)
    {
        require(
            patients[_patientId].status != Status.Critical,
            "Patient: Patient already has critical status"
        );
        address holder = patientHolder(_patientId);
        address emergencyAddress = getPatientEmergencyHospital(_patientId);

        if (holder != emergencyAddress) {
            patients[_patientId].status = Status.Critical;
            _transferPatientFrom(holder, emergencyAddress, _patientId);
        }
    }

    function _transferPatientFrom(
        address _from,
        address _to,
        uint256 _patientId
    ) internal {
        super.transferFrom(_from, _to, _patientId);
    }
}
