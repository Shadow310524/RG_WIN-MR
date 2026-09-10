"""
Seed script to generate rich, realistic mock data for RG WIN field sales & commercial CRM.
Used for physical device testing and walkthrough verification.

Run:
    python scripts/seed_mock_data.py

To remove mock data later:
    python scripts/clear_mock_data.py
"""
import asyncio
import os
import sys
import uuid

# Ensure backend root is in sys.path
sys.path.insert(0, os.path.dirname(os.path.dirname(os.path.abspath(__file__))))

from datetime import date, datetime, timedelta, timezone
from decimal import Decimal
from sqlalchemy import select, delete

from app.core.database import async_session_maker, engine
from app.core.security import hash_password
from app.models.user import User, RoleEnum, UserStatusEnum
from app.models.area import Area, AreaStatusEnum
from app.models.association import Association, AssociationStatusEnum
from app.models.mr_assignment import MRAreaAssignment
from app.models.doctor import Doctor, DoctorStatusEnum
from app.models.visit import (
    Visit,
    VisitTypeEnum,
    DoctorResponseEnum,
    PrescriptionPotentialEnum,
)
from app.models.promotional_investment import (
    DoctorPromotionalInvestment,
    PromotionalInvestmentTypeEnum,
)
from app.models.sale import Sale, SaleStatusEnum
from app.models.follow_up import FollowUp, FollowUpStatusEnum
from app.models.expense import Expense, ExpenseCategoryEnum
from app.core.logging import logger

MOCK_TAG = "[MOCK_DATA]"


async def seed_mock_data():
    async with async_session_maker() as session:
        logger.info("Starting RG WIN mock data seeding...")

        # 1. Ensure MR User
        mr_email = "mr.ravi@healix.com"
        mr_res = await session.execute(select(User).where(User.email == mr_email))
        mr = mr_res.scalars().first()
        if not mr:
            mr = User(
                id=uuid.uuid4(),
                email=mr_email,
                password_hash=hash_password("MrHealix2026!"),
                full_name="Ravi Kumar (MR)",
                phone="+919876543211",
                role=RoleEnum.MR,
                status=UserStatusEnum.ACTIVE,
            )
            session.add(mr)
            await session.flush()
            logger.info(f"Created MR user: {mr.email}")

        # 2. Ensure Admin User
        admin_email = "admin@healix.com"
        admin_res = await session.execute(select(User).where(User.email == admin_email))
        admin = admin_res.scalars().first()
        if not admin:
            admin = User(
                id=uuid.uuid4(),
                email=admin_email,
                password_hash=hash_password("AdminHealix2026!"),
                full_name="Dr. Harish Renganathan (Admin)",
                phone="+919876543210",
                role=RoleEnum.ADMIN,
                status=UserStatusEnum.ACTIVE,
            )
            session.add(admin)
            await session.flush()
            logger.info(f"Created Admin user: {admin.email}")

        # 3. Create Areas
        area_data = [
            {"name": "Anna Nagar", "code": "CHEN-AN-01", "desc": "Chennai North-West territory"},
            {"name": "T. Nagar", "code": "CHEN-TN-02", "desc": "Central commercial & clinic zone"},
            {"name": "Adyar", "code": "CHEN-AD-03", "desc": "Chennai South hospital cluster"},
            {"name": "Velachery", "code": "CHEN-VL-04", "desc": "South residential & multi-speciality"},
        ]
        areas = {}
        for ad in area_data:
            stmt = select(Area).where(Area.code == ad["code"])
            existing = (await session.execute(stmt)).scalars().first()
            if not existing:
                a = Area(
                    id=uuid.uuid4(),
                    name=ad["name"],
                    code=ad["code"],
                    description=f"{MOCK_TAG} {ad['desc']}",
                    status=AreaStatusEnum.ACTIVE,
                )
                session.add(a)
                await session.flush()
                areas[ad["code"]] = a
            else:
                areas[ad["code"]] = existing

        # 4. Assign MR to all Areas
        for a in areas.values():
            stmt = select(MRAreaAssignment).where(
                MRAreaAssignment.mr_id == mr.id,
                MRAreaAssignment.area_id == a.id,
            )
            assignment = (await session.execute(stmt)).scalars().first()
            if not assignment:
                assign = MRAreaAssignment(
                    id=uuid.uuid4(),
                    mr_id=mr.id,
                    area_id=a.id,
                    is_active=True,
                )
                session.add(assign)
        await session.flush()

        # 5. Create Associations
        assoc_data = [
            {"name": "Indian Medical Association (IMA)", "code": "IMA-CHN", "short": "IMA"},
            {"name": "Cardiological Society of India (CSI)", "code": "CSI-CHN", "short": "CSI"},
            {"name": "Association of Physicians of India (API)", "code": "API-CHN", "short": "API"},
        ]
        assocs = {}
        for asd in assoc_data:
            stmt = select(Association).where(Association.code == asd["code"])
            existing = (await session.execute(stmt)).scalars().first()
            if not existing:
                assoc = Association(
                    id=uuid.uuid4(),
                    name=asd["name"],
                    code=asd["code"],
                    short_name=asd["short"],
                    description=f"{MOCK_TAG} Medical association",
                    status=AssociationStatusEnum.ACTIVE,
                )
                session.add(assoc)
                await session.flush()
                assocs[asd["code"]] = assoc
            else:
                assocs[asd["code"]] = existing

        # 6. Create Doctors
        doctors_info = [
            {
                "name": "Dr. Anitha Ramesh",
                "phone": "+919840123451",
                "license": "MCI/2012/33401",
                "spec": "Cardiology",
                "clinic": "Apollo Heart Centre",
                "address": "12, 2nd Avenue, Anna Nagar, Chennai",
                "area_code": "CHEN-AN-01",
                "assoc_code": "CSI-CHN",
            },
            {
                "name": "Dr. Sundaram K",
                "phone": "+919840123452",
                "license": "MCI/2008/18204",
                "spec": "Diabetology",
                "clinic": "Sundaram Diabetes Clinic",
                "address": "45, Pondy Bazaar, T. Nagar, Chennai",
                "area_code": "CHEN-TN-02",
                "assoc_code": "API-CHN",
            },
            {
                "name": "Dr. Rajesh Khanna",
                "phone": "+919840123453",
                "license": "MCI/2015/78211",
                "spec": "Orthopedics",
                "clinic": "Khanna Bone & Joint Care",
                "address": "88, Shanthi Colony, Anna Nagar, Chennai",
                "area_code": "CHEN-AN-01",
                "assoc_code": "IMA-CHN",
            },
            {
                "name": "Dr. Meenakshi S",
                "phone": "+919840123454",
                "license": "MCI/2016/55490",
                "spec": "General Medicine",
                "clinic": "Meenakshi Health Clinic",
                "address": "5, Gandhi Nagar, Adyar, Chennai",
                "area_code": "CHEN-AD-03",
                "assoc_code": "IMA-CHN",
            },
            {
                "name": "Dr. Karthik Raja",
                "phone": "+919840123455",
                "license": "MCI/2011/90123",
                "spec": "Cardiology",
                "clinic": "Raja Cardio Speciality",
                "address": "22, Venkatnarayana Road, T. Nagar, Chennai",
                "area_code": "CHEN-TN-02",
                "assoc_code": "CSI-CHN",
            },
            {
                "name": "Dr. Priya Venkatesh",
                "phone": "+919840123456",
                "license": "MCI/2018/66782",
                "spec": "Pediatrics",
                "clinic": "Little Stars Child Care",
                "address": "14, Bypass Road, Velachery, Chennai",
                "area_code": "CHEN-VL-04",
                "assoc_code": "IMA-CHN",
            },
            {
                "name": "Dr. Venkatesh Prasad",
                "phone": "+919840123457",
                "license": "MCI/2005/11299",
                "spec": "Consultant Physician",
                "clinic": "Prasad Medical Centre",
                "address": "77, Lattice Bridge Road, Adyar, Chennai",
                "area_code": "CHEN-AD-03",
                "assoc_code": "API-CHN",
            },
            {
                "name": "Dr. Deepa Subramaniam",
                "phone": "+919840123458",
                "license": "MCI/2019/44301",
                "spec": "Endocrinology",
                "clinic": "Chennai Endo Care",
                "address": "33, 100 Feet Road, Velachery, Chennai",
                "area_code": "CHEN-VL-04",
                "assoc_code": "API-CHN",
            },
        ]

        doctors = {}
        for dinfo in doctors_info:
            stmt = select(Doctor).where(Doctor.medical_license_number == dinfo["license"])
            existing = (await session.execute(stmt)).scalars().first()
            if not existing:
                doc = Doctor(
                    id=uuid.uuid4(),
                    name=dinfo["name"],
                    phone=dinfo["phone"],
                    medical_license_number=dinfo["license"],
                    specialization=dinfo["spec"],
                    clinic_name=dinfo["clinic"],
                    address=dinfo["address"],
                    area_id=areas[dinfo["area_code"]].id,
                    association_id=assocs[dinfo["assoc_code"]].id,
                    notes=f"{MOCK_TAG} Seeded demonstration doctor profile",
                    status=DoctorStatusEnum.ACTIVE,
                    created_by=mr.id,
                )
                session.add(doc)
                await session.flush()
                doctors[dinfo["license"]] = doc
            else:
                doctors[dinfo["license"]] = existing

        # 7. Create Visits
        now = datetime.now(timezone.utc)
        today = date.today()

        visit_specs = [
            (
                "MCI/2012/33401",  # Dr. Anitha Ramesh
                now - timedelta(hours=2),
                VisitTypeEnum.REGULAR_VISIT,
                DoctorResponseEnum.PRESCRIBING,
                PrescriptionPotentialEnum.HIGH,
                "Detailed Healix-Cardio 50mg clinical efficacy data. Doctor confirmed Rx initiation.",
            ),
            (
                "MCI/2008/18204",  # Dr. Sundaram K
                now - timedelta(hours=4),
                VisitTypeEnum.PRODUCT_DISCUSSION,
                DoctorResponseEnum.POSITIVE,
                PrescriptionPotentialEnum.HIGH,
                "Discussed glycemic management protocols with Healix-Metformin dual release.",
            ),
            (
                "MCI/2011/90123",  # Dr. Karthik Raja
                now - timedelta(hours=6),
                VisitTypeEnum.REGULAR_VISIT,
                DoctorResponseEnum.PRESCRIBING,
                PrescriptionPotentialEnum.HIGH,
                "Presented latest ACC guideline data supporting Healix-Cardio therapy.",
            ),
            (
                "MCI/2015/78211",  # Dr. Rajesh Khanna
                now - timedelta(days=2, hours=4),
                VisitTypeEnum.ORDER_DISCUSSION,
                DoctorResponseEnum.POSITIVE,
                PrescriptionPotentialEnum.MEDIUM,
                "Reviewed surgical patient rehabilitation supplement packages. Reordering discussed.",
            ),
            (
                "MCI/2016/55490",  # Dr. Meenakshi S
                now - timedelta(days=3, hours=5),
                VisitTypeEnum.REGULAR_VISIT,
                DoctorResponseEnum.INTERESTED,
                PrescriptionPotentialEnum.MEDIUM,
                "Detailed general multivitamin and antibiotic line. Requested trial samples.",
            ),
            (
                "MCI/2005/11299",  # Dr. Venkatesh Prasad
                now - timedelta(days=4, hours=2),
                VisitTypeEnum.PRODUCT_DISCUSSION,
                DoctorResponseEnum.POSITIVE,
                PrescriptionPotentialEnum.HIGH,
                "Hypertension management case review. Confirmed regular prescription flow.",
            ),
            (
                "MCI/2018/66782",  # Dr. Priya Venkatesh
                now - timedelta(days=5, hours=3),
                VisitTypeEnum.REGULAR_VISIT,
                DoctorResponseEnum.POSITIVE,
                PrescriptionPotentialEnum.MEDIUM,
                "Pediatric cough formula presentation. Taste and tolerance approved.",
            ),
            (
                "MCI/2019/44301",  # Dr. Deepa Subramaniam
                now - timedelta(days=6, hours=2),
                VisitTypeEnum.NEW_DOCTOR,
                DoctorResponseEnum.INTERESTED,
                PrescriptionPotentialEnum.MEDIUM,
                "Initial territory introduction. Presented Healix endocrinology portfolio.",
            ),
        ]

        visits = []
        for license_num, vtime, vtype, resp, pot, feedback in visit_specs:
            doc = doctors[license_num]
            v = Visit(
                id=uuid.uuid4(),
                doctor_id=doc.id,
                user_id=mr.id,
                visit_datetime=vtime,
                visit_type=vtype,
                doctor_response=resp,
                prescription_potential=pot,
                doctor_feedback=feedback,
                notes=f"{MOCK_TAG} Field visit recording",
            )
            session.add(v)
            visits.append(v)
        await session.flush()

        # 8. Create Promotional Investments (Directly attributable doctor investments)
        promo_specs = [
            (
                "MCI/2012/33401",  # Dr. Anitha Ramesh
                Decimal("2500.00"),
                PromotionalInvestmentTypeEnum.SAMPLE,
                today,
                "Cardiology trial starter packs (10 patient boxes)",
                visits[0].id,
            ),
            (
                "MCI/2008/18204",  # Dr. Sundaram K
                Decimal("1800.00"),
                PromotionalInvestmentTypeEnum.FREE_SUPPLY,
                today,
                "Glucometer diagnostic strip bundles for patient education",
                visits[1].id,
            ),
            (
                "MCI/2011/90123",  # Dr. Karthik Raja
                Decimal("1500.00"),
                PromotionalInvestmentTypeEnum.PROMOTIONAL_MATERIAL,
                today,
                "Patient dietary guidance desk standees & educational charts",
                visits[2].id,
            ),
            (
                "MCI/2015/78211",  # Dr. Rajesh Khanna
                Decimal("3200.00"),
                PromotionalInvestmentTypeEnum.PROMOTIONAL_UNIT,
                today - timedelta(days=2),
                "Joint mobility therapy clinical demo sets",
                visits[3].id,
            ),
            (
                "MCI/2016/55490",  # Dr. Meenakshi S
                Decimal("1200.00"),
                PromotionalInvestmentTypeEnum.SAMPLE,
                today - timedelta(days=3),
                "Multivitamin promotional trial kit",
                visits[4].id,
            ),
            (
                "MCI/2005/11299",  # Dr. Venkatesh Prasad
                Decimal("2100.00"),
                PromotionalInvestmentTypeEnum.FREE_SUPPLY,
                today - timedelta(days=4),
                "Hypertension tracking charts and digital log supplies",
                visits[5].id,
            ),
            (
                "MCI/2018/66782",  # Dr. Priya Venkatesh
                Decimal("950.00"),
                PromotionalInvestmentTypeEnum.SAMPLE,
                today - timedelta(days=5),
                "Pediatric cough syrup starter samples",
                visits[6].id,
            ),
            (
                "MCI/2019/44301",  # Dr. Deepa Subramaniam
                Decimal("1100.00"),
                PromotionalInvestmentTypeEnum.PROMOTIONAL_MATERIAL,
                today - timedelta(days=6),
                "Endocrine clinical reference guides and trial kits",
                visits[7].id,
            ),
        ]

        for license_num, amt, itype, idate, notes, vid in promo_specs:
            doc = doctors[license_num]
            pi = DoctorPromotionalInvestment(
                id=uuid.uuid4(),
                doctor_id=doc.id,
                visit_id=vid,
                user_id=mr.id,
                amount=amt,
                investment_type=itype,
                investment_date=idate,
                notes=f"{MOCK_TAG} {notes}",
            )
            session.add(pi)
        await session.flush()

        # 9. Create Commercial Sales / Recorded Purchases
        # (Explicit purchases with user-entered GST)
        purchase_specs = [
            (
                "MCI/2012/33401",  # Dr. Anitha Ramesh
                Decimal("45000.00"),
                Decimal("8100.00"),
                Decimal("53100.00"),
                today,
                "Apollo Pharmacy hospital order #APO-2026-901",
            ),
            (
                "MCI/2008/18204",  # Dr. Sundaram K
                Decimal("32000.00"),
                Decimal("5760.00"),
                Decimal("37760.00"),
                today,
                "Sundaram Clinic bulk monthly restock #SC-1029",
            ),
            (
                "MCI/2011/90123",  # Dr. Karthik Raja
                Decimal("38000.00"),
                Decimal("6840.00"),
                Decimal("44840.00"),
                today,
                "Raja Cardio Centre prescription fulfillment #RCC-88",
            ),
            (
                "MCI/2015/78211",  # Dr. Rajesh Khanna
                Decimal("28000.00"),
                Decimal("5040.00"),
                Decimal("33040.00"),
                today - timedelta(days=2),
                "Orthopedic post-op supplement stock #KBJ-44",
            ),
            (
                "MCI/2016/55490",  # Dr. Meenakshi S
                Decimal("15000.00"),
                Decimal("2700.00"),
                Decimal("17700.00"),
                today - timedelta(days=3),
                "Meenakshi Clinic introductory purchase #MFH-12",
            ),
            (
                "MCI/2005/11299",  # Dr. Venkatesh Prasad
                Decimal("22000.00"),
                Decimal("3960.00"),
                Decimal("25960.00"),
                today - timedelta(days=4),
                "Adyar Community Clinic monthly batch #ACC-31",
            ),
            (
                "MCI/2018/66782",  # Dr. Priya Venkatesh
                Decimal("12000.00"),
                Decimal("2160.00"),
                Decimal("14160.00"),
                today - timedelta(days=5),
                "Little Stars pharmacy order #LSC-09",
            ),
            (
                "MCI/2019/44301",  # Dr. Deepa Subramaniam
                Decimal("18500.00"),
                Decimal("3330.00"),
                Decimal("21830.00"),
                today - timedelta(days=6),
                "Chennai Endo Care initial bulk purchase #CEC-05",
            ),
        ]

        for license_num, pamt, gst, total, pdate, notes in purchase_specs:
            doc = doctors[license_num]
            sale = Sale(
                id=uuid.uuid4(),
                doctor_id=doc.id,
                user_id=mr.id,
                sale_date=pdate,
                status=SaleStatusEnum.CONFIRMED,
                total_amount=pamt,  # Base purchase value
            )
            session.add(sale)
        await session.flush()

        # 10. Create Actionable Follow-ups
        followup_specs = [
            (
                "MCI/2012/33401",  # Dr. Anitha Ramesh
                today + timedelta(days=3),
                FollowUpStatusEnum.PENDING,
                "Deliver updated phase 4 clinical cardiology publication to clinic desk",
                visits[0].id,
            ),
            (
                "MCI/2008/18204",  # Dr. Sundaram K
                today + timedelta(days=1),
                FollowUpStatusEnum.PENDING,
                "Collect hospital quarterly purchase requisition form",
                visits[1].id,
            ),
            (
                "MCI/2015/78211",  # Dr. Rajesh Khanna
                today + timedelta(days=5),
                FollowUpStatusEnum.PENDING,
                "Review patient mobility outcomes after 14-day starter packs",
                visits[2].id,
            ),
            (
                "MCI/2011/90123",  # Dr. Karthik Raja
                today - timedelta(days=2),
                FollowUpStatusEnum.COMPLETED,
                "Delivered ACC clinical reference guidelines",
                visits[3].id,
            ),
        ]

        for license_num, ddate, fstatus, fnotes, vid in followup_specs:
            doc = doctors[license_num]
            fu = FollowUp(
                id=uuid.uuid4(),
                doctor_id=doc.id,
                visit_id=vid,
                assigned_user_id=mr.id,
                due_date=ddate,
                status=fstatus,
                notes=f"{MOCK_TAG} {fnotes}",
                completed_at=now if fstatus == FollowUpStatusEnum.COMPLETED else None,
            )
            session.add(fu)
        await session.flush()

        # 11. Create General Operating Expenses (Strictly separate at MR operational level)
        operating_expenses = [
            (
                ExpenseCategoryEnum.TRAVEL,
                Decimal("1850.00"),
                today - timedelta(days=1),
                "Territory vehicle fuel & toll charges across Anna Nagar and T. Nagar",
                areas["CHEN-AN-01"].id,
            ),
            (
                ExpenseCategoryEnum.TRAVEL,
                Decimal("920.00"),
                today - timedelta(days=3),
                "Inter-city highway toll and parking passes",
                areas["CHEN-TN-02"].id,
            ),
            (
                ExpenseCategoryEnum.OTHER,
                Decimal("480.00"),
                today - timedelta(days=2),
                "Field travel lunch & refreshments during hospital visiting hours",
                areas["CHEN-AD-03"].id,
            ),
        ]

        for cat, amt, edate, notes, aid in operating_expenses:
            exp = Expense(
                id=uuid.uuid4(),
                category=cat,
                amount=amt,
                area_id=aid,
                user_id=mr.id,
                doctor_id=None,  # NEVER attributed to individual doctors
                expense_date=edate,
                notes=f"{MOCK_TAG} {notes}",
            )
            session.add(exp)

        await session.commit()
        logger.info("Successfully seeded all RG WIN mock CRM & financial data!")
        print("\n=======================================================")
        print("  RG WIN MOCK DATA SEEDED SUCCESSFULLY! [Ready for physical device]")
        print("=======================================================")
        print(f"  MR Login: mr.ravi@healix.com / MrHealix2026!")
        print(f"  Admin Login: admin@healix.com / AdminHealix2026!")
        print(f"  Areas: 4 (Anna Nagar, T. Nagar, Adyar, Velachery)")
        print(f"  Doctors: 8 doctors enrolled with clinics & affiliations")
        print(f"  Visits: 8 field detailing visits recorded")
        print(f"  Promotional Investments: 8 doctor-specific investments (total: Rs. 14,350)")
        print(f"  Commercial Purchases: 8 purchases recorded (total: Rs. 210,500)")
        print(f"  Follow-ups: 4 actionable follow-ups (3 pending, 1 completed)")
        print(f"  Operating Expenses: 3 field operating expenses (total: Rs. 3,250)")
        print("=======================================================\n")

    await engine.dispose()


if __name__ == "__main__":
    asyncio.run(seed_mock_data())
