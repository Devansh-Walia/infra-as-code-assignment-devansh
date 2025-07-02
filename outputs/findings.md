### Why is it a bad idea to crtl+c when you have run a apply command?

if you notice that first command that runs when you plan or apply is

| Acquiring state lock. This may take a few moments...

this lock needs to be released for the operation to end successfully. if you press crtl+c to end this operation you encounter error like the one given below:

> Error: Error acquiring the state lock
>
> Error message: operation error S3: PutObject, https response error StatusCode: 412, RequestID: 4XQB4Z24HZH3PF8B, HostID:
> tv2vXf6XLzqm549w/XegSbdTdN3VAipGDPQ3e8Hx36tbKvW3hUDoxQj/qYFUI5pK1DH3pQ9CqhNhvWATLK3kn65Sb4uniDtxH7b7yLFfWCc=, api error PreconditionFailed: At least one of the pre-conditions you specified
> did not hold
>
> Lock Info:
>
> ID: 067007ee-1347-f6a5-152c-7b02b4e16689\
>  Path: deva-terraform-state-d3700965/dev/terraform.tfstate\
>  Operation: OperationTypeApply\
>  Who: devanshwalia@Devanshs-MacBook-Pro.local\
>  Version: 1.12.2\
>  Created: 2025-07-02 16:28:51.292103 +0000 UTC\
>
> Info: \
>  Terraform acquires a state lock to protect the state from being written
> │ by multiple users at the same time. Please resolve the issue above and try
> │ again. For most commands, you can disable locking with the "-lock=false"
> │ flag, but this is not recommended.

---

Which means that one you start an operation it obtains a lock id and thus if you stop it in between the lock is not able to release before ending the process hence starting a new one would break the code and this error would pop.

#### how to resolve this?

you'll need to check if any process is running or not using:
`ps aux | grep terraform`

if not you'll release the lock with

`terraform force-unlock <lock-id-that-the-error-showed-in-the-above-error>`

then you'll be able to perform the specific task successfully
