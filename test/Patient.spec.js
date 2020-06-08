const BigNumber = require("bignumber.js");
const truffleAssert = require("truffle-assertions");

const Patient = artifacts.require("Patient");

contract("Contract Test", (accounts) => {
    const hospital1 = accounts[0];
    const hospital2 = accounts[1];
    const hospitalEmergency = accounts[2];
    const patientName = "Michael Jackson";
    const dateBirth = +new Date();
    let patientInstance;

    // Deploy a new contract before each test to prevent one test from interfering with the other
    beforeEach(async () => {
        patientInstance = await Patient.new();
    });

    it('should add a new patient', async () => {
        const tx = await patientInstance.addPatient(patientName, dateBirth, hospitalEmergency, { from: hospital1 })

        truffleAssert.eventEmitted(tx, "Transfer", (obj) => {
            return (
                obj._from === hospital1 &&
                obj._to === hospital1 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            )
        }, 'Fail addPatient');
    });

    it('should transfer a patient from a hospital to another', async () => {
        const tx1 = await patientInstance.addPatient(patientName, dateBirth, hospitalEmergency, { from: hospital1 })

        truffleAssert.eventEmitted(tx1, "Transfer", (obj) => {
            return (
                obj._from === hospital1 &&
                obj._to === hospital1 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, 'Fail addPatient');

        let holderAddress = await patientInstance.ownerOf(1);
        assert.equal(holderAddress, hospital1, `Hospital should be ${hospital1}`);

        const tx2 = await patientInstance.transferPatient(hospital2, 1, { from: hospital1 });

        truffleAssert.eventEmitted(tx2, "Transfer", (obj) => {
            return (
                obj._from === hospital1 &&
                obj._to === hospital2 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, 'Fail addPatient');

        holderAddress = await patientInstance.ownerOf(1);
        assert.equal(holderAddress, hospital2, `Hospital should be ${hospital2}`);
    });

    it('should return patient info', async () => {
        const tx1 = await patientInstance.addPatient(patientName, dateBirth, hospitalEmergency, { from: hospital1 });

        truffleAssert.eventEmitted(tx1, "Transfer", (obj) => {
            return (
                obj._from === hospital1 &&
                obj._to === hospital1 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, 'Fail addPatient');

        const nameReturn = await patientInstance.getPatientName(1, { from: hospital1 });
        assert.equal(nameReturn, patientName, `Patient name should be ${patientName}`);

        const dateBirthReturn = await patientInstance.getPatientDateBirth(1, { from: hospital1 });
        assert.equal(dateBirthReturn, dateBirth, `Patient date birth should be ${dateBirth}`);

        const statusReturn = await patientInstance.getPatientStatus(1, { from: hospital1 });
        assert(new BigNumber(statusReturn).isEqualTo(0), 'Patient status should be 0');

        const emergencyReturn = await patientInstance.getPatientEmergencyHospital(1, { from: hospital1 });
        assert.equal(emergencyReturn, hospitalEmergency, `Patient emergency hospital address should be ${hospitalEmergency}`);
    });

    it('should move critical patients to emergency hospital', async () => {
        const tx1 = await patientInstance.addPatient(patientName, dateBirth, hospitalEmergency, { from: hospital1 });

        truffleAssert.eventEmitted(tx1, "Transfer", (obj) => {
            return (
                obj._from === hospital1 &&
                obj._to === hospital1 &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, 'Fail addPatient');

        const tx2 = await patientInstance.movePatientToCritical(1, { from: hospital1 });

        truffleAssert.eventEmitted(tx2, "Transfer", (obj) => {
            return (
                obj._from === hospital1 &&
                obj._to === hospitalEmergency &&
                new BigNumber(1).isEqualTo(obj._tokenId)
            );
        }, `Fail transfer patient from ${hospital1} to ${hospitalEmergency}`);
    });
});